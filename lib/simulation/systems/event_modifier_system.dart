import '../models/game_state.dart';

abstract final class EventModifierSystem {
  static GameState expireDueModifiers(GameState state) {
    var changed = false;
    final ghosts = state.ghosts
        .map((ghost) {
          final expiresAt = ghost.eventModifierExpiresAtActiveSecond;
          if (expiresAt == null || expiresAt > state.activeSimulationSeconds) {
            return ghost;
          }
          changed = true;
          return ghost.copyWith(
            eventHappinessModifier: 0,
            eventModifierExpiresAtActiveSecond: null,
          );
        })
        .toList(growable: false);
    return changed ? state.copyWith(ghosts: ghosts) : state;
  }

  static int? secondsUntilNextExpiry(GameState state) {
    int? next;
    for (final ghost in state.ghosts) {
      final expiresAt = ghost.eventModifierExpiresAtActiveSecond;
      if (expiresAt == null) continue;
      final remaining = expiresAt - state.activeSimulationSeconds;
      if (remaining <= 0) return 0;
      if (next == null || remaining < next) next = remaining;
    }
    return next;
  }
}
