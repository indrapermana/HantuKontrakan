import '../content/ghost_definitions.dart';
import '../content/progression_definitions.dart';
import '../models/game_state.dart';
import '../models/ghost.dart';

abstract final class ProgressionSystem {
  static int levelForExperience(int experience) {
    var level = 1;
    for (final definition in ProgressionDefinitions.levels) {
      if (experience < definition.requiredExperience) break;
      level = definition.level;
    }
    return level;
  }

  static GameState grantExperience(GameState state, int amount) {
    if (amount <= 0) return state;
    final maximum = ProgressionDefinitions.levels.last.requiredExperience;
    final experience = (state.playerExperience + amount).clamp(0, maximum);
    final level = levelForExperience(experience);
    if (experience == state.playerExperience && level == state.playerLevel) {
      return state;
    }
    return state.copyWith(playerExperience: experience, playerLevel: level);
  }

  static bool isGhostUnlocked(GameState state, GhostKind kind) =>
      state.playerLevel >= GhostDefinitions.byKind(kind).unlockLevel;

  static bool isRoomEligible(GameState state, String roomId) =>
      state.playerLevel >= ProgressionDefinitions.requiredLevelForRoom(roomId);
}
