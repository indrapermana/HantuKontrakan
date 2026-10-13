import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/application/game_controller.dart';
import 'package:hantu_kontrakan/application/simulation_runtime.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
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
}

class _FixedClock implements GameClock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
