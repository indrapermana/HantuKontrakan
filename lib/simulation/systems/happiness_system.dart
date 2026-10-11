import '../constants/game_balance.dart';
import '../models/game_state.dart';
import '../models/ghost.dart';

abstract final class HappinessSystem {
  static const Map<GhostKind, Map<GhostKind, int>> _compatibility = {
    GhostKind.pocong: {GhostKind.tuyul: -15},
    GhostKind.tuyul: {GhostKind.pocong: -5},
  };

  static int compatibilityFor(GameState state, String ghostId) {
    final resident = state.ghostById(ghostId);
    final room = state.roomForGhost(ghostId);
    if (room == null) return 0;

    var total = 0;
    for (final neighborRoom in state.rooms) {
      if (neighborRoom.occupantId == null ||
          (neighborRoom.column - room.column).abs() != 1) {
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

  static int happinessFor(GameState state, String ghostId) {
    final ghost = state.ghostById(ghostId);
    final eventModifier = ghost.eventHappinessModifier.clamp(
      GameBalance.eventMinimum,
      GameBalance.eventMaximum,
    );
    return (GameBalance.baseHappiness +
            compatibilityFor(state, ghostId) +
            eventModifier)
        .clamp(0, 100);
  }

  static String moodFor(int happiness) {
    if (happiness >= 80) return 'Senang';
    if (happiness >= 60) return 'Nyaman';
    if (happiness >= 40) return 'Tidak senang';
    return 'Marah';
  }
}
