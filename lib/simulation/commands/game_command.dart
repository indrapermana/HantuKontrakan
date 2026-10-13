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
