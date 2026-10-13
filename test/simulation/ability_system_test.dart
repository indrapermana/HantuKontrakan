import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/constants/game_balance.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/systems/ability_system.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';
import 'package:hantu_kontrakan/simulation/systems/offline_earnings_system.dart';
import 'package:hantu_kontrakan/simulation/systems/rent_system.dart';

void main() {
  test('Pocong finds 30 coins after ten eligible active minutes', () {
    final initial = _residentState(
      kind: GhostKind.pocong,
      roomTagLevels: const {'quiet': 1},
      eventHappinessModifier: 20,
    );

    final almostReady = GameRules.advanceSimulation(initial, 599);
    final triggered = GameRules.advanceSimulation(almostReady, 1);

    expect(almostReady.walletCoins, 0);
    expect(almostReady.abilityCooldownSeconds['resident'], 1);
    expect(triggered.walletCoins, 30);
    expect(
      triggered.abilityCooldownSeconds['resident'],
      GameBalance.periodicAbilityIntervalSeconds,
    );
  });

  test('periodic rewards and cooldowns are chunk independent', () {
    final initial = _residentState(
      kind: GhostKind.pocong,
      roomTagLevels: const {'quiet': 1},
      eventHappinessModifier: 20,
    );
    final oneChunk = GameRules.advanceSimulation(initial, 1200);
    var manyChunks = initial;
    for (var second = 0; second < 1200; second += 1) {
      manyChunks = GameRules.advanceSimulation(manyChunks, 1);
    }

    expect(oneChunk.walletCoins, 60);
    expect(manyChunks.walletCoins, oneChunk.walletCoins);
    expect(manyChunks.abilityCooldownSeconds, oneChunk.abilityCooldownSeconds);
  });

  test('failed happiness check grants nothing and restarts cooldown', () {
    final initial = _residentState(kind: GhostKind.pocong);

    final advanced = GameRules.advanceSimulation(initial, 600);

    expect(advanced.walletCoins, 0);
    expect(advanced.abilityCooldownSeconds['resident'], 600);
  });

  test('Kuntilanak grants reputation and respects the maximum', () {
    final initial = _residentState(
      kind: GhostKind.kuntilanak,
      reputation: 99,
      roomTagLevels: const {'plant': 1},
      eventHappinessModifier: 20,
    );

    final advanced = GameRules.advanceSimulation(initial, 1200);

    expect(advanced.reputation, GameBalance.maximumReputation);
    expect(advanced.walletCoins, 0);
  });

  test('Tuyul continuous ability adds fifteen percent base rent', () {
    final state = _residentState(
      kind: GhostKind.tuyul,
      eventHappinessModifier: 10,
    );

    expect(RentSystem.rentPerMinuteMicrocoinsFor(state, 'resident'), 13800000);
  });

  test('Genderuwo gives a 25 percent repair discount at happiness 60', () {
    final eligible = _residentState(
      kind: GhostKind.genderuwo,
      roomTagLevels: const {'sturdy': 1},
    );
    final ineligible = _residentState(kind: GhostKind.genderuwo);

    expect(AbilitySystem.repairCostFor(eligible, 'room_01', 100), 75);
    expect(AbilitySystem.repairCostFor(ineligible, 'room_01', 100), 100);
    expect(AbilitySystem.repairCostFor(eligible, 'unknown', 100), 100);
  });

  test('offline earnings never advance or trigger active abilities', () {
    final active = GameRules.advanceSimulation(
      _residentState(
        kind: GhostKind.pocong,
        roomTagLevels: const {'quiet': 1},
        eventHappinessModifier: 20,
      ),
      300,
    );
    final paused = OfflineEarningsSystem.pause(active, 0);
    final resumed = OfflineEarningsSystem.resume(
      paused,
      240 * GameBalance.millisecondsPerMinute,
    );

    expect(resumed.walletCoins, 0);
    expect(resumed.activeSimulationSeconds, 300);
    expect(resumed.abilityCooldownSeconds['resident'], 300);
    expect(resumed.pendingRentMicrocoins, greaterThan(0));
  });
}

GameState _residentState({
  required GhostKind kind,
  int chaos = 0,
  int reputation = GameBalance.initialReputation,
  int eventHappinessModifier = 0,
  Map<String, int> roomTagLevels = const {},
}) => GameState(
  schemaVersion: GameState.currentSchemaVersion,
  walletCoins: 0,
  chaos: chaos,
  reputation: reputation,
  ghosts: [
    GhostState(
      id: 'resident',
      kind: kind,
      eventHappinessModifier: eventHappinessModifier,
    ),
  ],
  rooms: [
    RoomState(
      id: 'room_01',
      column: 0,
      occupantId: 'resident',
      roomTagLevels: roomTagLevels,
    ),
  ],
  complaintResolved: false,
);
