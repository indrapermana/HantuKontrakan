import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/constants/game_balance.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/incident_definition.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';
import 'package:hantu_kontrakan/simulation/systems/incident_system.dart';

void main() {
  test('chance follows the documented chaos formula and cap', () {
    expect(IncidentSystem.chanceForChaos(40), 1200);
    expect(IncidentSystem.chanceForChaos(80), 2000);
    expect(IncidentSystem.chanceForChaos(1000), 3500);
  });

  test(
    'eligibility requires resident tenants, happiness, level, and chaos',
    () {
      const definitions = [
        IncidentDefinition(id: 'general'),
        IncidentDefinition(
          id: 'unhappy_pocong',
          requiredGhostKind: GhostKind.pocong,
          maximumGhostHappiness: 39,
        ),
        IncidentDefinition(
          id: 'kuntilanak',
          requiredGhostKind: GhostKind.kuntilanak,
        ),
        IncidentDefinition(id: 'high_chaos', minimumChaos: 70),
        IncidentDefinition(id: 'level_three', minimumPlayerLevel: 3),
      ];

      expect(
        IncidentSystem.eligibleDefinitions(
          GameState.seeded(),
          definitions: definitions,
        ).map((definition) => definition.id),
        ['general', 'unhappy_pocong'],
      );
    },
  );

  test('checks only each active minute and never overlaps incidents', () {
    const random = _AlwaysZeroRandom();
    final beforeCheck = GameRules.advanceSimulation(
      GameState.seeded(),
      59,
      incidentRandomSource: random,
    );
    final spawned = GameRules.advanceSimulation(
      beforeCheck,
      1,
      incidentRandomSource: random,
    );
    final whilePending = GameRules.advanceSimulation(
      spawned,
      600,
      incidentRandomSource: random,
    );

    expect(beforeCheck.activeIncidentId, isNull);
    expect(spawned.activeIncidentId, isNotNull);
    expect(whilePending.activeIncidentId, spawned.activeIncidentId);
    expect(whilePending.unscriptedIncidentSpawnTimes, [60]);
  });

  test(
    'resolution is idempotent and enforces three active minute cooldown',
    () {
      const random = _AlwaysZeroRandom();
      final spawned = GameRules.advanceSimulation(
        GameState.seeded(),
        60,
        incidentRandomSource: random,
      );
      final resolved = GameRules.resolveIncident(
        spawned,
        spawned.activeIncidentId!,
        'resolution-1',
      );
      final replayed = GameRules.resolveIncident(
        resolved,
        spawned.activeIncidentId!,
        'resolution-1',
      );
      final stillCoolingDown = GameRules.advanceSimulation(
        resolved,
        179,
        incidentRandomSource: random,
      );
      final allowed = GameRules.advanceSimulation(
        stillCoolingDown,
        1,
        incidentRandomSource: random,
      );

      expect(resolved.activeIncidentId, isNull);
      expect(resolved.completedIncidentResolutionIds, {'resolution-1'});
      expect(identical(replayed, resolved), isTrue);
      expect(stillCoolingDown.activeIncidentId, isNull);
      expect(allowed.activeIncidentId, isNotNull);
      expect(allowed.activeIncidentId, isNot(spawned.activeIncidentId));
    },
  );

  test('rolling window permits no more than three incidents', () {
    const random = _AlwaysZeroRandom();
    final capped = GameState.seeded().copyWith(
      activeSimulationSeconds: 600,
      unscriptedIncidentSpawnTimes: const [60, 240, 420],
    );

    expect(
      IncidentSystem.check(capped, randomSource: random).activeIncidentId,
      isNull,
    );

    final expiredOldest = capped.copyWith(activeSimulationSeconds: 660);
    final spawned = IncidentSystem.check(expiredOldest, randomSource: random);
    expect(spawned.activeIncidentId, isNotNull);
    expect(spawned.unscriptedIncidentSpawnTimes, [240, 420, 660]);
  });

  test('same seed produces identical sequence across chunking and reload', () {
    final initial = GameState.seeded().copyWith(
      incidentRandomState: 12345,
      chaos: GameBalance.maximumChaos,
    );
    final oneChunk = GameRules.advanceSimulation(initial, 900);
    var minuteChunks = initial;
    for (var minute = 0; minute < 15; minute += 1) {
      minuteChunks = GameRules.advanceSimulation(minuteChunks, 60);
    }
    final restored = GameState.fromJson(
      jsonDecode(jsonEncode(oneChunk.toJson())) as Map<String, Object?>,
    );

    expect(minuteChunks.toJson(), oneChunk.toJson());
    expect(restored.toJson(), oneChunk.toJson());
    expect(restored.incidentRandomState, oneChunk.incidentRandomState);
  });

  test('offline resume does not check or advance incident scheduling', () {
    final paused = GameRules.pauseForOffline(GameState.seeded(), 0);
    final resumed = GameRules.resumeFromOffline(paused, 600000);

    expect(resumed.activeSimulationSeconds, 0);
    expect(resumed.activeIncidentId, isNull);
    expect(resumed.incidentRandomState, paused.incidentRandomState);
    expect(resumed.unscriptedIncidentSpawnTimes, isEmpty);
  });
}

class _AlwaysZeroRandom implements IncidentRandomSource {
  const _AlwaysZeroRandom();

  @override
  IncidentRandomDraw draw(int state, int upperBound) =>
      IncidentRandomDraw(value: 0, nextState: (state + 1) & 0xffffffff);
}
