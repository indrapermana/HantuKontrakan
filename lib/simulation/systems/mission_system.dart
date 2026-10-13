import '../content/mission_definitions.dart';
import '../models/game_state.dart';
import '../models/mission_definition.dart';
import '../models/room.dart';
import 'happiness_system.dart';
import 'progression_system.dart';

abstract final class MissionSystem {
  static bool isComplete(GameState state, MissionDefinition mission) {
    return switch (mission.objective) {
      MissionObjective.placeGhost =>
        state.roomForGhost(mission.targetId!) != null,
      MissionObjective.collectRent => state.completedRentClaimIds.isNotEmpty,
      MissionObjective.resolveIncident =>
        state.completedIncidentResolutionIds.isNotEmpty,
      MissionObjective.upgradeComfort => state.rooms.any(
        (room) => room.levelFor(RoomAttribute.comfort) >= mission.targetValue,
      ),
      MissionObjective.equipFurniture => state.rooms.any(
        (room) => room.furnitureIds.isNotEmpty,
      ),
      MissionObjective.reachHappiness =>
        state.rooms
            .where((room) => room.occupantId != null)
            .any(
              (room) =>
                  HappinessSystem.happinessFor(state, room.occupantId!) >=
                  mission.targetValue,
            ),
      MissionObjective.unlockRoom => state.rooms.any(
        (room) => room.id == mission.targetId && room.unlocked,
      ),
      MissionObjective.reachLevel => state.playerLevel >= mission.targetValue,
    };
  }

  static bool isClaimable(GameState state, MissionDefinition mission) {
    final prerequisite = mission.prerequisiteMissionId;
    return !state.completedMissionIds.contains(mission.id) &&
        (prerequisite == null ||
            state.completedMissionIds.contains(prerequisite)) &&
        isComplete(state, mission);
  }

  static GameState claim(GameState state, String missionId) {
    if (missionId.trim().isEmpty) return state;
    final mission = MissionDefinitions.byId(missionId);
    if (mission == null || !isClaimable(state, mission)) return state;
    final reward = mission.reward;
    final rewarded = state.copyWith(
      walletCoins: state.walletCoins + reward.coins,
      mysticalCrystals: state.mysticalCrystals + reward.mysticalCrystals,
      completedMissionIds: {...state.completedMissionIds, mission.id},
    );
    return ProgressionSystem.grantExperience(rewarded, reward.experience);
  }
}
