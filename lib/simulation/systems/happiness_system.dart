import '../constants/game_balance.dart';
import '../content/ghost_definitions.dart';
import '../models/game_state.dart';
import '../models/ghost.dart';

abstract final class HappinessSystem {
  static const Map<GhostKind, Map<GhostKind, int>> _compatibility = {
    GhostKind.pocong: {
      GhostKind.kuntilanak: 5,
      GhostKind.tuyul: -15,
      GhostKind.genderuwo: 10,
    },
    GhostKind.kuntilanak: {
      GhostKind.pocong: 10,
      GhostKind.tuyul: 5,
      GhostKind.genderuwo: -10,
    },
    GhostKind.tuyul: {
      GhostKind.pocong: -5,
      GhostKind.kuntilanak: 10,
      GhostKind.genderuwo: -15,
    },
    GhostKind.genderuwo: {
      GhostKind.pocong: 10,
      GhostKind.kuntilanak: -5,
      GhostKind.tuyul: -10,
    },
  };

  static int compatibilityFor(GameState state, String ghostId) {
    final resident = state.ghostById(ghostId);
    final room = state.roomForGhost(ghostId);
    if (room == null) return 0;

    var total = 0;
    for (final neighborRoom in state.rooms) {
      if (neighborRoom.occupantId == null ||
          (neighborRoom.column - room.column).abs() +
                  (neighborRoom.row - room.row).abs() !=
              1) {
        continue;
      }
      final neighbor = state.ghostById(neighborRoom.occupantId!);
      total += _compatibility[resident.kind]?[neighbor.kind] ?? 0;
    }
    return total.clamp(
      GameBalance.compatibilityMinimum,
      GameBalance.compatibilityMaximum,
    );
  }

  static int roomPreferenceFor(GameState state, String ghostId) {
    final ghost = state.ghostById(ghostId);
    final room = state.roomForGhost(ghostId);
    if (room == null || room.roomTagLevels.isEmpty) return 0;
    final preferred = GhostDefinitions.byKind(ghost.kind).preferredRoomTags;
    final total = room.roomTagLevels.entries.fold(
      0,
      (score, entry) =>
          score +
          (preferred.contains(entry.key)
              ? GameBalance.roomTagMatchHappinessByLevel[entry.value]!
              : GameBalance.roomTagMismatchHappinessByLevel[entry.value]!),
    );
    return total.clamp(
      GameBalance.roomPreferenceMinimum,
      GameBalance.roomPreferenceMaximum,
    );
  }

  static int furniturePreferenceFor(GameState state, String ghostId) {
    final ghost = state.ghostById(ghostId);
    final room = state.roomForGhost(ghostId);
    if (room == null || room.furnitureTags.isEmpty) return 0;
    final preferred = GhostDefinitions.byKind(ghost.kind).preferredRoomTags;
    final total = room.furnitureTags.fold(
      0,
      (score, tag) =>
          score +
          (preferred.contains(tag)
              ? GameBalance.furnitureTagMatchHappiness
              : GameBalance.furnitureTagMismatchHappiness),
    );
    return total.clamp(
      GameBalance.furniturePreferenceMinimum,
      GameBalance.furniturePreferenceMaximum,
    );
  }

  static int happinessFor(GameState state, String ghostId) {
    return breakdownFor(state, ghostId).total;
  }

  static HappinessBreakdown breakdownFor(GameState state, String ghostId) {
    final ghost = state.ghostById(ghostId);
    final eventModifier = ghost.eventHappinessModifier.clamp(
      GameBalance.eventMinimum,
      GameBalance.eventMaximum,
    );
    final roomPreference = roomPreferenceFor(state, ghostId);
    final furniturePreference = furniturePreferenceFor(state, ghostId);
    final compatibility = compatibilityFor(state, ghostId);
    return HappinessBreakdown(
      base: GameBalance.baseHappiness,
      roomPreference: roomPreference,
      furniturePreference: furniturePreference,
      compatibility: compatibility,
      event: eventModifier,
      total:
          (GameBalance.baseHappiness +
                  roomPreference +
                  furniturePreference +
                  compatibility +
                  eventModifier)
              .clamp(0, 100),
    );
  }

  static HappinessMood moodFor(int happiness) {
    if (happiness >= 80) return HappinessMood.happy;
    if (happiness >= 60) return HappinessMood.comfortable;
    if (happiness >= 40) return HappinessMood.unhappy;
    return HappinessMood.angry;
  }
}

enum HappinessMood { happy, comfortable, unhappy, angry }

class HappinessBreakdown {
  const HappinessBreakdown({
    required this.base,
    required this.roomPreference,
    required this.furniturePreference,
    required this.compatibility,
    required this.event,
    required this.total,
  });

  final int base;
  final int roomPreference;
  final int furniturePreference;
  final int compatibility;
  final int event;
  final int total;
}
