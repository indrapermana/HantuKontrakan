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

final class PurchaseFurniture extends GameCommand {
  const PurchaseFurniture({required this.furnitureId});
  final String furnitureId;
}

final class UnlockSecondProperty extends GameCommand {
  const UnlockSecondProperty();
}

final class SwitchProperty extends GameCommand {
  const SwitchProperty({required this.propertyId});
  final String propertyId;
}

final class CompleteGhostStory extends GameCommand {
  const CompleteGhostStory({required this.ghostId});
  final String ghostId;
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

final class CollectRoomRent extends GameCommand {
  const CollectRoomRent({required this.roomId, required this.claimId});

  final String roomId;
  final String claimId;
}

final class BeginRewardedRentClaim extends GameCommand {
  const BeginRewardedRentClaim({
    required this.claimId,
    required this.localDayKey,
    required this.bonusCoins,
  });

  final String claimId;
  final String localDayKey;
  final int bonusCoins;
}

final class GrantRewardedRentBonus extends GameCommand {
  const GrantRewardedRentBonus({required this.claimId});

  final String claimId;
}

final class CancelRewardedRentClaim extends GameCommand {
  const CancelRewardedRentClaim({required this.claimId});

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

final class EnsureDailyGoals extends GameCommand {
  const EnsureDailyGoals({required this.dayKey});

  final String dayKey;
}

final class ClaimDailyGoal extends GameCommand {
  const ClaimDailyGoal({required this.goalId});

  final String goalId;
}

final class ClaimDailyChest extends GameCommand {
  const ClaimDailyChest();
}

final class SetLanguageCode extends GameCommand {
  const SetLanguageCode({required this.languageCode});

  final String languageCode;
}

final class SetAnalyticsConsent extends GameCommand {
  const SetAnalyticsConsent({required this.granted});

  final bool granted;
}

final class SetErrorReportingConsent extends GameCommand {
  const SetErrorReportingConsent({required this.granted});

  final bool granted;
}

final class SetAudioPreferences extends GameCommand {
  const SetAudioPreferences({
    required this.musicMuted,
    required this.soundMuted,
    required this.musicVolume,
    required this.soundVolume,
  });

  final bool musicMuted;
  final bool soundMuted;
  final double musicVolume;
  final double soundVolume;
}

final class SetFeedbackPreferences extends GameCommand {
  const SetFeedbackPreferences({
    required this.hapticsEnabled,
    required this.reducedMotionEnabled,
  });

  final bool hapticsEnabled;
  final bool reducedMotionEnabled;
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
