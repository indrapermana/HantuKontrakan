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
      SwapOccupants(:final roomId) => GameRules.swapOccupants(_state, roomId),
      ResolveComplaint(:final choice, :final resolutionId) =>
        GameRules.resolveComplaint(_state, choice, resolutionId),
      DebugTick(:final seconds) => GameRules.advanceDebugTick(_state, seconds),
      ResetGame() => GameState.seeded(),
    };
    if (identical(nextState, _state)) return false;

    _state = nextState;
    _revision += 1;
    return true;
  }
}
