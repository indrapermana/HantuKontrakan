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

final class AdvanceSimulation extends GameCommand {
  const AdvanceSimulation({required this.seconds});

  final int seconds;
}

final class CollectAllRent extends GameCommand {
  const CollectAllRent({required this.claimId});

  final String claimId;
}

final class ContinueTutorial extends GameCommand {
  const ContinueTutorial();
}

final class GrantExperience extends GameCommand {
  const GrantExperience({required this.amount});

  final int amount;
}

final class ClaimMissionReward extends GameCommand {
  const ClaimMissionReward({required this.missionId});

  final String missionId;
}

final class SetLanguageCode extends GameCommand {
  const SetLanguageCode({required this.languageCode});

  final String languageCode;
}

final class SetAnalyticsConsent extends GameCommand {
  const SetAnalyticsConsent({required this.granted});

  final bool granted;
}

final class ResolveIncident extends GameCommand {
  const ResolveIncident({
    required this.incidentId,
    required this.choiceId,
    required this.resolutionId,
  });

  final String incidentId;
  final String choiceId;
  final String resolutionId;
}

final class RepairRoom extends GameCommand {
  const RepairRoom({required this.roomId, required this.repairId});

  final String roomId;
  final String repairId;
}

final class PauseForOffline extends GameCommand {
  const PauseForOffline({required this.timestampMillis});

  final int timestampMillis;
}

final class ResumeFromOffline extends GameCommand {
  const ResumeFromOffline({required this.timestampMillis});

  final int timestampMillis;
}

final class ResetGame extends GameCommand {
  const ResetGame();
}

final class SetGhostSpecialAction extends GameCommand {
  const SetGhostSpecialAction({required this.ghostId, required this.active});

  final String ghostId;
  final bool active;
}
