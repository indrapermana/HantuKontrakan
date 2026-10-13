import '../constants/game_balance.dart';
import '../content/incident_definitions.dart';
import '../models/game_state.dart';
import '../models/incident_definition.dart';
import '../models/room.dart';
import 'happiness_system.dart';

class IncidentRandomDraw {
  const IncidentRandomDraw({required this.value, required this.nextState});

  final int value;
  final int nextState;
}

abstract interface class IncidentRandomSource {
  const IncidentRandomSource();

  IncidentRandomDraw draw(int state, int upperBound);
}

class SeededIncidentRandomSource implements IncidentRandomSource {
  const SeededIncidentRandomSource();

  @override
  IncidentRandomDraw draw(int state, int upperBound) {
    if (upperBound <= 0) throw ArgumentError.value(upperBound, 'upperBound');
    final nextState = (1664525 * state + 1013904223) & 0xffffffff;
    return IncidentRandomDraw(
      value: nextState % upperBound,
      nextState: nextState,
    );
  }
}

abstract final class IncidentSystem {
  static int secondsUntilNextCheck(GameState state) =>
      GameBalance.incidentCheckIntervalSeconds -
      (state.activeSimulationSeconds %
          GameBalance.incidentCheckIntervalSeconds);

  static int chanceForChaos(int chaos) =>
      (GameBalance.incidentBaseChance +
              GameBalance.incidentChancePerChaos * chaos)
          .clamp(0, GameBalance.maximumIncidentChance);

  static List<IncidentDefinition> eligibleDefinitions(
    GameState state, {
    List<IncidentDefinition> definitions = IncidentDefinitions.schedulerPool,
  }) => definitions
      .where((definition) {
        if (state.playerLevel < (definition.minimumPlayerLevel ?? 0) ||
            state.chaos < (definition.minimumChaos ?? 0) ||
            state.reputation < (definition.minimumReputation ?? 0)) {
          return false;
        }
        final occupiedRooms = state.rooms
            .where((room) => room.occupantId != null)
            .toList(growable: false);
        if (definition.requiresOccupiedRoom && occupiedRooms.isEmpty) {
          return false;
        }
        final requiredKind = definition.requiredGhostKind;
        final matchingRooms = requiredKind == null
            ? occupiedRooms
            : occupiedRooms
                  .where(
                    (room) =>
                        state.ghostById(room.occupantId!).kind == requiredKind,
                  )
                  .toList(growable: false);
        if (requiredKind != null && matchingRooms.isEmpty) return false;
        final maximumDurability = definition.maximumResidentRoomDurabilityLevel;
        if (maximumDurability != null &&
            !matchingRooms.any(
              (room) =>
                  room.levelFor(RoomAttribute.durability) <= maximumDurability,
            )) {
          return false;
        }
        final residents = matchingRooms.map(
          (room) => state.ghostById(room.occupantId!),
        );
        final maximumHappiness = definition.maximumGhostHappiness;
        final minimumHappiness = definition.minimumGhostHappiness;
        if (maximumHappiness == null && minimumHappiness == null) return true;
        return residents.any((ghost) {
          final happiness = HappinessSystem.happinessFor(state, ghost.id);
          return happiness <= (maximumHappiness ?? 100) &&
              happiness >= (minimumHappiness ?? 0);
        });
      })
      .toList(growable: false);

  static GameState check(
    GameState state, {
    IncidentRandomSource randomSource = const SeededIncidentRandomSource(),
    List<IncidentDefinition> definitions = IncidentDefinitions.schedulerPool,
  }) {
    if (!state.unscriptedIncidentsEnabled || state.activeIncidentId != null) {
      return state;
    }
    final resolvedAt = state.lastIncidentResolvedAtActiveSecond;
    final lastIncident = state.recentIncidentIds.isEmpty
        ? null
        : definitions
              .where(
                (definition) => definition.id == state.recentIncidentIds.last,
              )
              .firstOrNull;
    final requiredCooldown = lastIncident == null
        ? GameBalance.incidentCooldownSeconds
        : lastIncident.cooldownSeconds.clamp(
            GameBalance.incidentCooldownSeconds,
            1 << 31,
          );
    if (resolvedAt != null &&
        state.activeSimulationSeconds - resolvedAt < requiredCooldown) {
      return state;
    }
    final windowStart =
        state.activeSimulationSeconds -
        GameBalance.incidentRollingWindowSeconds;
    final recentSpawnTimes = state.unscriptedIncidentSpawnTimes
        .where((timestamp) => timestamp > windowStart)
        .toList(growable: false);
    if (recentSpawnTimes.length >=
        GameBalance.maximumIncidentsPerRollingWindow) {
      return recentSpawnTimes.length ==
              state.unscriptedIncidentSpawnTimes.length
          ? state
          : state.copyWith(unscriptedIncidentSpawnTimes: recentSpawnTimes);
    }

    var eligible = eligibleDefinitions(state, definitions: definitions);
    if (eligible.length > 1 && state.recentIncidentIds.isNotEmpty) {
      final mostRecent = state.recentIncidentIds.last;
      eligible = eligible
          .where((definition) => definition.id != mostRecent)
          .toList(growable: false);
    }
    if (eligible.isEmpty) return state;

    final chanceDraw = randomSource.draw(
      state.incidentRandomState,
      GameBalance.incidentChanceScale,
    );
    if (chanceDraw.value >= chanceForChaos(state.chaos)) {
      return state.copyWith(
        incidentRandomState: chanceDraw.nextState,
        unscriptedIncidentSpawnTimes: recentSpawnTimes,
      );
    }
    final selectionDraw = randomSource.draw(
      chanceDraw.nextState,
      eligible.length,
    );
    final selected = eligible[selectionDraw.value];
    final history = [...state.recentIncidentIds, selected.id];
    final trimmedHistory =
        history.length <= GameBalance.incidentRecentHistoryLength
        ? history
        : history.sublist(
            history.length - GameBalance.incidentRecentHistoryLength,
          );
    return state.copyWith(
      activeIncidentId: selected.id,
      incidentRandomState: selectionDraw.nextState,
      unscriptedIncidentSpawnTimes: [
        ...recentSpawnTimes,
        state.activeSimulationSeconds,
      ],
      recentIncidentIds: trimmedHistory,
    );
  }

  static GameState resolve(
    GameState state,
    String incidentId,
    String resolutionId,
  ) {
    if (incidentId.trim().isEmpty ||
        resolutionId.trim().isEmpty ||
        state.activeIncidentId != incidentId ||
        state.completedIncidentResolutionIds.contains(resolutionId)) {
      return state;
    }
    return state.copyWith(
      activeIncidentId: null,
      lastIncidentResolvedAtActiveSecond: state.activeSimulationSeconds,
      completedIncidentResolutionIds: {
        ...state.completedIncidentResolutionIds,
        resolutionId,
      },
    );
  }
}
