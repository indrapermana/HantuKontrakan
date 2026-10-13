import '../systems/game_rules.dart';
import '../models/room.dart';

sealed class GameCommand {
  const GameCommand();
}

final class PlaceGhost extends GameCommand {
  const PlaceGhost({required this.ghostId, required this.roomId});

  final String ghostId;
  final String roomId;
}

final class MoveGhost extends GameCommand {
  const MoveGhost({
    required this.ghostId,
    required this.targetRoomId,
    this.allowSwap = false,
  });

  final String ghostId;
  final String targetRoomId;
  final bool allowSwap;
}

final class UnlockRoom extends GameCommand {
  const UnlockRoom({required this.roomId});

  final String roomId;
}

final class UpgradeRoom extends GameCommand {
  const UpgradeRoom({required this.roomId, required this.attribute});

  final String roomId;
  final RoomAttribute attribute;
}

final class EquipFurniture extends GameCommand {
  const EquipFurniture({
    required this.roomId,
    required this.furnitureId,
    required this.slot,
  });

  final String roomId;
  final String furnitureId;
  final FurnitureSlot slot;
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
