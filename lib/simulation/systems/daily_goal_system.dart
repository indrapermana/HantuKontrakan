import '../commands/game_command.dart';
import '../constants/game_balance.dart';
import '../models/daily_goal_definition.dart';
import '../models/game_state.dart';
import '../models/mission_definition.dart';
import 'progression_system.dart';

abstract final class DailyGoalSystem {
  static const collectRentId = 'daily_collect_rent';
  static const activeManagementId = 'daily_active_management';
  static const tenantRequestId = 'daily_tenant_request';

  static const chestReward = MissionReward(coins: 50, experience: 30);

  static GameState ensureForDay(GameState state, String dayKey) {
    if (!_isDayKey(dayKey) || state.dailyGoalDayKey == dayKey) return state;
    final eligible = state.rooms.where((room) => room.unlocked).toList()
      ..sort((left, right) => left.id.compareTo(right.id));
    if (eligible.isEmpty) return state;
    final occupied = eligible
        .where((room) => room.occupantId != null)
        .toList(growable: false);
    final choices = occupied.isEmpty ? eligible : occupied;
    final dayNumber = int.parse(dayKey.replaceAll('-', ''));
    final tenantRoom = choices[dayNumber % choices.length];
    return state.copyWith(
      dailyGoalDayKey: dayKey,
      dailyTenantRoomId: tenantRoom.id,
      dailyGoalProgress: const {},
      completedDailyGoalIds: const {},
      dailyChestClaimed: false,
    );
  }

  static List<DailyGoalDefinition> definitions(GameState state) {
    final roomId = state.dailyTenantRoomId;
    if (state.dailyGoalDayKey == null || roomId == null) return const [];
    final roomNumber = _roomNumber(roomId);
    return [
      const DailyGoalDefinition(
        id: collectRentId,
        kind: DailyGoalKind.collectRent,
        title: LocalizedMissionText(id: 'Ronda Uang Sewa', en: 'Rent Rounds'),
        description: LocalizedMissionText(
          id: 'Ambil uang sewa sebanyak 2 kali.',
          en: 'Collect rent 2 times.',
        ),
        target: 2,
        reward: MissionReward(coins: 20, experience: 10),
      ),
      const DailyGoalDefinition(
        id: activeManagementId,
        kind: DailyGoalKind.activeManagement,
        title: LocalizedMissionText(
          id: 'Juragan Siaga',
          en: 'Hands-on Manager',
        ),
        description: LocalizedMissionText(
          id: 'Kelola kontrakan secara aktif selama 3 menit.',
          en: 'Actively manage the property for 3 minutes.',
        ),
        target: 180,
        reward: MissionReward(coins: 15, experience: 15),
      ),
      DailyGoalDefinition(
        id: tenantRequestId,
        kind: DailyGoalKind.tenantRequest,
        title: const LocalizedMissionText(
          id: 'Permintaan Penghuni',
          en: 'Tenant Request',
        ),
        description: LocalizedMissionText(
          id: 'Ambil uang sewa dari Kamar $roomNumber.',
          en: 'Collect rent from Room $roomNumber.',
        ),
        target: 1,
        roomId: roomId,
        reward: const MissionReward(coins: 25, experience: 20),
      ),
    ];
  }

  static int progressFor(GameState state, DailyGoalDefinition goal) =>
      (state.dailyGoalProgress[goal.id] ?? 0).clamp(0, goal.target);

  static bool isComplete(GameState state, DailyGoalDefinition goal) =>
      progressFor(state, goal) >= goal.target;

  static bool isClaimable(GameState state, DailyGoalDefinition goal) =>
      !state.completedDailyGoalIds.contains(goal.id) && isComplete(state, goal);

  static GameState record(
    GameState before,
    GameState after,
    GameCommand command,
  ) {
    if (identical(before, after) || after.dailyGoalDayKey == null) return after;
    final definitionsById = {
      for (final goal in definitions(after)) goal.id: goal,
    };
    if (definitionsById.length != 3) return after;
    final progress = Map<String, int>.of(after.dailyGoalProgress);

    if (command is AdvanceSimulation) {
      _increment(
        progress,
        definitionsById[activeManagementId]!,
        after.activeSimulationSeconds - before.activeSimulationSeconds,
      );
    }
    if (command is CollectAllRent || command is CollectRoomRent) {
      if (after.completedRentClaimIds.length >
          before.completedRentClaimIds.length) {
        _increment(progress, definitionsById[collectRentId]!, 1);
        final tenantGoal = definitionsById[tenantRequestId]!;
        final roomId = tenantGoal.roomId!;
        final beforeWhole =
            before.pendingRentMicrocoinsForRoom(roomId) ~/
            GameBalance.microcoinsPerCoin;
        final afterWhole =
            after.pendingRentMicrocoinsForRoom(roomId) ~/
            GameBalance.microcoinsPerCoin;
        if (beforeWhole > afterWhole) {
          _increment(progress, tenantGoal, 1);
        }
      }
    }
    if (_sameProgress(progress, after.dailyGoalProgress)) return after;
    return after.copyWith(dailyGoalProgress: progress);
  }

  static GameState claimGoal(GameState state, String goalId) {
    final goal = definitions(
      state,
    ).where((definition) => definition.id == goalId).firstOrNull;
    if (goal == null || !isClaimable(state, goal)) return state;
    final rewarded = state.copyWith(
      walletCoins: state.walletCoins + goal.reward.coins,
      mysticalCrystals: state.mysticalCrystals + goal.reward.mysticalCrystals,
      completedDailyGoalIds: {...state.completedDailyGoalIds, goal.id},
    );
    return ProgressionSystem.grantExperience(rewarded, goal.reward.experience);
  }

  static bool isChestClaimable(GameState state) {
    final definitionsForDay = definitions(state);
    return !state.dailyChestClaimed &&
        definitionsForDay.length == 3 &&
        definitionsForDay.every(
          (goal) => state.completedDailyGoalIds.contains(goal.id),
        );
  }

  static GameState claimChest(GameState state) {
    if (!isChestClaimable(state)) return state;
    final rewarded = state.copyWith(
      walletCoins: state.walletCoins + chestReward.coins,
      mysticalCrystals: state.mysticalCrystals + chestReward.mysticalCrystals,
      dailyChestClaimed: true,
    );
    return ProgressionSystem.grantExperience(rewarded, chestReward.experience);
  }

  static void _increment(
    Map<String, int> progress,
    DailyGoalDefinition goal,
    int amount,
  ) {
    if (amount <= 0) return;
    progress[goal.id] = ((progress[goal.id] ?? 0) + amount).clamp(
      0,
      goal.target,
    );
  }

  static bool _sameProgress(Map<String, int> left, Map<String, int> right) {
    if (left.length != right.length) return false;
    return left.entries.every((entry) => right[entry.key] == entry.value);
  }

  static bool _isDayKey(String value) =>
      RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value);

  static int _roomNumber(String roomId) =>
      int.tryParse(roomId.split('_').last) ?? 0;
}
