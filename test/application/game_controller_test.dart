import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/application/game_controller.dart';
import 'package:hantu_kontrakan/application/simulation_runtime.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';

void main() {
  test(
    'resolved complaint and swapped rooms survive controller reload',
    () async {
      final saves = MemorySaveService();
      final first = GameController(saveService: saves);
      await first.initialize();
      await first.moveGhost('pocong_01', 'room_02', allowSwap: true);
      await first.resolveComplaint(ComplaintChoice.peaceOffering);

      final reloaded = GameController(saveService: saves);
      await reloaded.initialize();

      expect(reloaded.state.walletCoins, 175);
      expect(reloaded.state.complaintResolved, isTrue);
      expect(reloaded.state.roomById('room_01').occupantId, 'tuyul_01');
      expect(reloaded.happinessFor('pocong_01'), 40);
    },
  );

  test('rejected save seeds safely and exposes recovery reason', () async {
    final saves = MemorySaveService(
      initialResult: const SaveRejected(
        reason: SaveRejectionReason.unsupportedVersion,
        schemaVersion: 99,
      ),
    );
    final controller = GameController(saveService: saves);

    await controller.initialize();

    expect(controller.state.walletCoins, 200);
    expect(
      controller.saveRecoveryReason,
      SaveRejectionReason.unsupportedVersion,
    );
    expect(saves.storedResult, isA<SaveRejected>());
  });

  test('debug clock, seed, tick and reset are deterministic', () async {
    final clock = _FixedClock(DateTime.utc(2026, 10, 13, 12));
    final saves = MemorySaveService();
    final controller = GameController(
      saveService: saves,
      clock: clock,
      randomSeed: 42,
    );
    await controller.initialize();

    expect(controller.debugNow, DateTime.utc(2026, 10, 13, 12));
    expect(controller.randomSeed, 42);
    expect(controller.state.chaos, 40);
    expect(controller.state.activeSimulationSeconds, 0);

    await controller.debugTick();
    expect(controller.state.activeSimulationSeconds, 1);
    expect(saves.storedState?.activeSimulationSeconds, 1);

    await controller.resolveComplaint(ComplaintChoice.installSoundproofing);
    expect(controller.state.walletCoins, 150);
    await controller.resetState();

    expect(controller.state.walletCoins, 200);
    expect(controller.state.chaos, 40);
    expect(controller.state.activeSimulationSeconds, 0);
    expect(controller.state.complaintResolved, isFalse);
    expect(saves.storedState?.walletCoins, 200);
  });

  test('rent claim remains idempotent after controller reload', () async {
    final initial = GameState.seeded().copyWith(pendingRentMicrocoins: 2250000);
    final saves = MemorySaveService(initialResult: SaveLoaded(initial));
    final first = GameController(saveService: saves);
    await first.initialize();
    await first.collectAllRent(claimId: 'stable-claim');

    final reloaded = GameController(saveService: saves);
    await reloaded.initialize();
    await reloaded.collectAllRent(claimId: 'stable-claim');

    expect(reloaded.state.walletCoins, 202);
    expect(reloaded.state.pendingRentMicrocoins, 250000);
    expect(reloaded.state.completedRentClaimIds, {'stable-claim'});
  });

  test('initialize credits persisted offline snapshot exactly once', () async {
    final pausedAt = DateTime.utc(2026, 10, 13, 8);
    final resumedAt = pausedAt.add(const Duration(hours: 2));
    final initial = GameState.seeded().copyWith(
      offlineRateSnapshotMicrocoinsPerMinute: 40000000,
      lastOfflineAccrualTimestampMillis: pausedAt.millisecondsSinceEpoch,
    );
    final saves = MemorySaveService(initialResult: SaveLoaded(initial));
    final clock = _MutableClock(resumedAt);

    final first = GameController(saveService: saves, clock: clock);
    await first.initialize();
    final credited = first.state.pendingRentMicrocoins;

    final reloaded = GameController(saveService: saves, clock: clock);
    await reloaded.initialize();

    expect(credited, 2400000000);
    expect(reloaded.state.pendingRentMicrocoins, credited);
    expect(reloaded.state.offlineRateSnapshotMicrocoinsPerMinute, isNull);
  });

  test('pause persists one rate snapshot for lifecycle resume', () async {
    final clock = _MutableClock(DateTime.utc(2026, 10, 13, 8));
    final saves = MemorySaveService();
    final controller = GameController(saveService: saves, clock: clock);
    await controller.initialize();

    await controller.pauseForOffline();
    final firstTimestamp = saves.storedState?.lastOfflineAccrualTimestampMillis;
    clock.value = clock.value.add(const Duration(minutes: 10));
    await controller.pauseForOffline();

    expect(
      saves.storedState?.offlineRateSnapshotMicrocoinsPerMinute,
      greaterThan(0),
    );
    expect(
      saves.storedState?.lastOfflineAccrualTimestampMillis,
      firstTimestamp,
    );
  });

  test('overlapping lifecycle saves remain ordered', () async {
    final clock = _MutableClock(DateTime.utc(2026, 10, 13, 8));
    final saves = _ReorderingSaveService();
    final controller = GameController(saveService: saves, clock: clock);
    await controller.initialize();

    final pause = controller.pauseForOffline();
    clock.value = clock.value.add(const Duration(hours: 2));
    final resume = controller.resumeFromOffline();
    await Future.wait([pause, resume]);

    expect(saves.storedState?.offlineRateSnapshotMicrocoinsPerMinute, isNull);
    expect(saves.storedState?.pendingRentMicrocoins, greaterThan(0));
  });

  test('ability cooldown continues after controller reload', () async {
    final initial = GameState(
      schemaVersion: GameState.currentSchemaVersion,
      walletCoins: 0,
      chaos: 0,
      ghosts: const [
        GhostState(
          id: 'pocong_01',
          kind: GhostKind.pocong,
          eventHappinessModifier: 20,
        ),
      ],
      rooms: [
        RoomState(
          id: 'room_01',
          column: 0,
          occupantId: 'pocong_01',
          roomTagLevels: const {'quiet': 1},
        ),
      ],
      complaintResolved: false,
    );
    final saves = MemorySaveService(initialResult: SaveLoaded(initial));
    final first = GameController(saveService: saves);
    await first.initialize();
    await first.advanceSimulation(300);

    final reloaded = GameController(saveService: saves);
    await reloaded.initialize();
    await reloaded.advanceSimulation(300);

    expect(reloaded.state.walletCoins, 30);
    expect(reloaded.state.abilityCooldownSeconds['pocong_01'], 600);
  });

  test(
    'repair persists and duplicate controller request cannot charge twice',
    () async {
      final seed = GameState.seeded();
      final damaged = seed.copyWith(
        rooms: seed.rooms
            .map(
              (room) => room.id == 'room_01'
                  ? room.copyWith(
                      occupantId: room.occupantId,
                      repairRequired: true,
                      upgrades: const {RoomAttribute.durability: 1},
                    )
                  : room,
            )
            .toList(growable: false),
      );
      final saves = MemorySaveService(initialResult: SaveLoaded(damaged));
      final first = GameController(saveService: saves);
      await first.initialize();

      expect(first.repairCostFor('room_01'), 80);
      expect(
        await first.repairRoom('room_01', repairId: 'stable-repair'),
        isTrue,
      );
      expect(
        await first.repairRoom('room_01', repairId: 'stable-repair'),
        isFalse,
      );

      final reloaded = GameController(saveService: saves);
      await reloaded.initialize();
      expect(reloaded.state.walletCoins, 120);
      expect(reloaded.state.roomById('room_01').repairRequired, isFalse);
      expect(reloaded.state.completedRepairIds, {'stable-repair'});
    },
  );
}

class _FixedClock implements GameClock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

class _MutableClock implements GameClock {
  _MutableClock(this.value);

  DateTime value;

  @override
  DateTime now() => value;
}

class _ReorderingSaveService implements SaveService {
  GameState? storedState;

  @override
  Future<SaveLoadResult> load() async => const SaveNotFound();

  @override
  Future<void> save(GameState state) async {
    if (state.offlineRateSnapshotMicrocoinsPerMinute != null) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    storedState = state;
  }
}
