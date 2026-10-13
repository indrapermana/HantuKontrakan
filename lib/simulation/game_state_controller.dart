import 'commands/game_command.dart';
import 'models/game_state.dart';
import 'systems/game_rules.dart';

class GameStateController {
  GameStateController(GameState initialState) : _state = initialState;

  GameState _state;
  int _revision = 0;

  GameState get state => _state;
  int get revision => _revision;

  bool dispatch(GameCommand command) {
    final nextState = switch (command) {
      PlaceGhost(:final ghostId, :final roomId) => GameRules.placeGhost(
        _state,
        ghostId,
        roomId,
      ),
      MoveGhost(:final ghostId, :final targetRoomId, :final allowSwap) =>
        GameRules.moveGhost(
          _state,
          ghostId,
          targetRoomId,
          allowSwap: allowSwap,
        ),
      ResolveComplaint(:final choice, :final resolutionId) =>
        GameRules.resolveComplaint(_state, choice, resolutionId),
      DebugTick(:final seconds) => GameRules.advanceDebugTick(_state, seconds),
      ResetGame() => GameState.seeded(),
      SetGhostSpecialAction(:final ghostId, :final active) =>
        GameRules.setGhostSpecialAction(_state, ghostId, active),
    };
    if (identical(nextState, _state)) return false;

    _state = nextState;
    _revision += 1;
    return true;
  }
}
