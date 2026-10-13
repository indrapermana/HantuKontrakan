class LocalizedMissionText {
  const LocalizedMissionText({required this.id, required this.en});

  final String id;
  final String en;
}

enum MissionObjective {
  placeGhost,
  collectRent,
  resolveIncident,
  upgradeComfort,
  equipFurniture,
  reachHappiness,
  unlockRoom,
  reachLevel,
}

class MissionReward {
  const MissionReward({
    this.coins = 0,
    this.experience = 0,
    this.mysticalCrystals = 0,
  });

  final int coins;
  final int experience;
  final int mysticalCrystals;
}

class MissionDefinition {
  const MissionDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.objective,
    required this.reward,
    this.prerequisiteMissionId,
    this.targetId,
    this.targetValue = 1,
  });

  final String id;
  final LocalizedMissionText title;
  final LocalizedMissionText description;
  final MissionObjective objective;
  final MissionReward reward;
  final String? prerequisiteMissionId;
  final String? targetId;
  final int targetValue;
}
