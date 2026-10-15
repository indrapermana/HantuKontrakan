import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/commands/game_command.dart';
import 'package:hantu_kontrakan/simulation/constants/game_balance.dart';
import 'package:hantu_kontrakan/simulation/game_state_controller.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/systems/daily_goal_system.dart';

void main() {
  test('daily schedule is deterministic, stable, and uses unlocked rooms', () {
    final seed = GameState.seeded();
    final first = DailyGoalSystem.ensureForDay(seed, '2026-10-15');
    final repeated = DailyGoalSystem.ensureForDay(first, '2026-10-15');
    final next = DailyGoalSystem.ensureForDay(
      first.copyWith(
        dailyGoalProgress: const {
          DailyGoalSystem.collectRentId: 2,
          DailyGoalSystem.activeManagementId: 180,
          DailyGoalSystem.tenantRequestId: 1,
        },
        completedDailyGoalIds: const {
          DailyGoalSystem.collectRentId,
          DailyGoalSystem.activeManagementId,
          DailyGoalSystem.tenantRequestId,
        },
        dailyChestClaimed: true,
      ),
      '2026-10-16',
    );

    expect(repeated, same(first));
    expect(first.dailyTenantRoomId, 'room_02');
    expect(seed.roomById(first.dailyTenantRoomId!).unlocked, isTrue);
    expect(next.dailyTenantRoomId, 'room_01');
    expect(next.dailyGoalProgress, isEmpty);
    expect(next.completedDailyGoalIds, isEmpty);
    expect(next.dailyChestClaimed, isFalse);
    expect(DailyGoalSystem.definitions(first), hasLength(3));
  });

  test('active progress is chunk independent and survives reload', () {
    final initial = DailyGoalSystem.ensureForDay(
      GameState.seeded(),
      '2026-10-15',
    );
    final oneChunk = GameStateController(initial)
      ..dispatch(const AdvanceSimulation(seconds: 180));
    final split = GameStateController(initial)
      ..dispatch(const AdvanceSimulation(seconds: 60))
      ..dispatch(const AdvanceSimulation(seconds: 120));

    expect(oneChunk.state.dailyGoalProgress, split.state.dailyGoalProgress);
    expect(
      oneChunk.state.dailyGoalProgress[DailyGoalSystem.activeManagementId],
      180,
    );
    final restored = GameState.fromJson(oneChunk.state.toJson());
    expect(restored.dailyGoalProgress, oneChunk.state.dailyGoalProgress);
    expect(restored.dailyGoalDayKey, '2026-10-15');
  });

  test('rent and tenant request progress only on successful base claims', () {
    final scheduled = DailyGoalSystem.ensureForDay(
      GameState.seeded(),
      '2026-10-15',
    );
    final tenantRoomId = scheduled.dailyTenantRoomId!;
    final ready = scheduled.copyWith(
      pendingRentMicrocoinsByRoom: {
        tenantRoomId: 2 * GameBalance.microcoinsPerCoin,
      },
    );
    final controller = GameStateController(ready);

    expect(
      controller.dispatch(
        CollectRoomRent(roomId: tenantRoomId, claimId: 'daily-rent-1'),
      ),
      isTrue,
    );
    final afterClaim = controller.state;
    controller.dispatch(
      CollectRoomRent(roomId: tenantRoomId, claimId: 'daily-rent-1'),
    );

    expect(afterClaim.dailyGoalProgress[DailyGoalSystem.collectRentId], 1);
    expect(afterClaim.dailyGoalProgress[DailyGoalSystem.tenantRequestId], 1);
    expect(controller.state.dailyGoalProgress, afterClaim.dailyGoalProgress);
  });

  test('goal rewards and chest are exact once and do not require ads', () {
    var state = DailyGoalSystem.ensureForDay(GameState.seeded(), '2026-10-15')
        .copyWith(
          dailyGoalProgress: const {
            DailyGoalSystem.collectRentId: 2,
            DailyGoalSystem.activeManagementId: 180,
            DailyGoalSystem.tenantRequestId: 1,
          },
        );
    final walletBefore = state.walletCoins;
    for (final goal in DailyGoalSystem.definitions(state)) {
      final claimed = DailyGoalSystem.claimGoal(state, goal.id);
      expect(DailyGoalSystem.claimGoal(claimed, goal.id), same(claimed));
      state = claimed;
    }
    expect(DailyGoalSystem.isChestClaimable(state), isTrue);
    final chest = DailyGoalSystem.claimChest(state);
    expect(DailyGoalSystem.claimChest(chest), same(chest));
    expect(chest.dailyChestClaimed, isTrue);
    expect(chest.walletCoins, walletBefore + 20 + 15 + 25 + 50);
    expect(chest.completedRewardedRentClaimIds, isEmpty);
  });

  test('invalid day and incomplete claims preserve identity', () {
    final state = GameState.seeded();
    expect(DailyGoalSystem.ensureForDay(state, 'not-a-day'), same(state));
    expect(DailyGoalSystem.claimGoal(state, 'unknown'), same(state));
    expect(DailyGoalSystem.claimChest(state), same(state));
  });
}
