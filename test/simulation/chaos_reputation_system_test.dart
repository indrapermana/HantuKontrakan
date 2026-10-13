import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/constants/game_balance.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/systems/chaos_reputation_system.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';
import 'package:hantu_kontrakan/simulation/systems/offline_earnings_system.dart';

void main() {
  test('seeded residents update chaos only at ten active minutes', () {
    final initial = GameState.seeded();
    final almost = GameRules.advanceSimulation(initial, 599);
    final ticked = GameRules.advanceSimulation(almost, 1);

    expect(almost.chaos, 40);
    expect(ticked.chaos, 45);
    expect(ticked.activeSimulationSeconds, 600);
  });

  test('chaos and economy remain chunk independent across ticks', () {
    final initial = GameState.seeded();
    final oneChunk = GameRules.advanceSimulation(initial, 1200);
    var manyChunks = initial;
    for (var second = 0; second < 1200; second += 1) {
      manyChunks = GameRules.advanceSimulation(manyChunks, 1);
    }

    expect(oneChunk.chaos, 50);
    expect(manyChunks.toJson(), oneChunk.toJson());
  });

  test('occupied contributions and chaos bounds are exact', () {
    final crowded = _allResidentsState(chaos: 98);
    final calming = GameState(
      schemaVersion: GameState.currentSchemaVersion,
      walletCoins: 0,
      chaos: 1,
      ghosts: const [GhostState(id: 'genderuwo', kind: GhostKind.genderuwo)],
      rooms: [RoomState(id: 'room', column: 0, occupantId: 'genderuwo')],
      complaintResolved: false,
    );

    expect(GameRules.advanceSimulation(crowded, 600).chaos, 100);
    expect(GameRules.advanceSimulation(calming, 600).chaos, 0);
  });

  test('event chaos and reputation deltas clamp to zero through 100', () {
    final state = GameState.seeded();
    final upper = ChaosReputationSystem.applyEventDeltas(
      state,
      chaosDelta: 999,
      reputationDelta: 999,
    );
    final lower = ChaosReputationSystem.applyEventDeltas(
      state,
      chaosDelta: -999,
      reputationDelta: -999,
    );

    expect(upper.chaos, 100);
    expect(upper.reputation, 100);
    expect(lower.chaos, 0);
    expect(lower.reputation, 0);
  });

  test('complaint happiness modifier expires after active duration', () {
    final initial = GameState.seeded().copyWith(activeSimulationSeconds: 100);
    final resolved = GameRules.resolveComplaint(
      initial,
      ComplaintChoice.installSoundproofing,
      'expiring-resolution',
    );
    final almost = GameRules.advanceSimulation(resolved, 599);
    final expired = GameRules.advanceSimulation(almost, 1);

    expect(
      resolved.ghostById('pocong_01').eventModifierExpiresAtActiveSecond,
      700,
    );
    expect(almost.ghostById('pocong_01').eventHappinessModifier, 20);
    expect(expired.ghostById('pocong_01').eventHappinessModifier, 0);
    expect(
      expired.ghostById('pocong_01').eventModifierExpiresAtActiveSecond,
      isNull,
    );
  });

  test('offline resume changes no chaos, reputation, or modifier timer', () {
    final active = GameState.seeded().copyWith(
      reputation: 72,
      ghosts: GameState.seeded().ghosts
          .map(
            (ghost) => ghost.id == 'pocong_01'
                ? ghost.copyWith(
                    eventHappinessModifier: 20,
                    eventModifierExpiresAtActiveSecond: 600,
                  )
                : ghost,
          )
          .toList(growable: false),
    );
    final paused = OfflineEarningsSystem.pause(active, 0);
    final resumed = OfflineEarningsSystem.resume(
      paused,
      240 * GameBalance.millisecondsPerMinute,
    );

    expect(resumed.activeSimulationSeconds, 0);
    expect(resumed.chaos, 40);
    expect(resumed.reputation, 72);
    expect(resumed.ghostById('pocong_01').eventHappinessModifier, 20);
    expect(
      resumed.ghostById('pocong_01').eventModifierExpiresAtActiveSecond,
      600,
    );
  });
}

GameState _allResidentsState({required int chaos}) => GameState(
  schemaVersion: GameState.currentSchemaVersion,
  walletCoins: 0,
  chaos: chaos,
  ghosts: const [
    GhostState(id: 'pocong', kind: GhostKind.pocong),
    GhostState(id: 'kuntilanak', kind: GhostKind.kuntilanak),
    GhostState(id: 'tuyul', kind: GhostKind.tuyul),
    GhostState(id: 'genderuwo', kind: GhostKind.genderuwo),
  ],
  rooms: [
    RoomState(id: 'one', column: 0, occupantId: 'pocong'),
    RoomState(id: 'two', column: 1, occupantId: 'kuntilanak'),
    RoomState(id: 'three', column: 2, occupantId: 'tuyul'),
    RoomState(id: 'four', column: 3, occupantId: 'genderuwo'),
  ],
  complaintResolved: false,
);
