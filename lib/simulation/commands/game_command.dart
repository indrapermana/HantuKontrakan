import '../systems/game_rules.dart';

sealed class GameCommand {
  const GameCommand();
}

final class SwapOccupants extends GameCommand {
  const SwapOccupants({required this.roomId});

  final String roomId;
}

final class ResolveComplaint extends GameCommand {
  const ResolveComplaint({required this.choice, required this.resolutionId});

  final ComplaintChoice choice;
  final String resolutionId;
}

final class DebugTick extends GameCommand {
  const DebugTick({this.seconds = 1});

  final int seconds;
}

final class ResetGame extends GameCommand {
  const ResetGame();
}

final class SetGhostSpecialAction extends GameCommand {
  const SetGhostSpecialAction({required this.ghostId, required this.active});

  final String ghostId;
  final bool active;
}
