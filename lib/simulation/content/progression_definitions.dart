import '../models/ghost.dart';
import '../models/progression_level_definition.dart';

abstract final class ProgressionDefinitions {
  static const List<ProgressionLevelDefinition> levels = [
    ProgressionLevelDefinition(
      level: 1,
      requiredExperience: 0,
      unlockedGhostKinds: {GhostKind.pocong},
      unlockedRoomIds: {'room_01'},
    ),
    ProgressionLevelDefinition(
      level: 2,
      requiredExperience: 100,
      unlockedGhostKinds: {GhostKind.kuntilanak},
      unlockedRoomIds: {'room_02'},
    ),
    ProgressionLevelDefinition(
      level: 3,
      requiredExperience: 250,
      unlockedGhostKinds: {GhostKind.tuyul},
      unlockedRoomIds: {'room_03'},
    ),
    ProgressionLevelDefinition(level: 4, requiredExperience: 450),
    ProgressionLevelDefinition(
      level: 5,
      requiredExperience: 700,
      unlockedGhostKinds: {GhostKind.genderuwo},
      unlockedRoomIds: {'room_04'},
    ),
    ProgressionLevelDefinition(level: 6, requiredExperience: 1000),
    ProgressionLevelDefinition(level: 7, requiredExperience: 1400),
    ProgressionLevelDefinition(level: 8, requiredExperience: 1900),
    ProgressionLevelDefinition(level: 9, requiredExperience: 2500),
    ProgressionLevelDefinition(level: 10, requiredExperience: 3200),
  ];

  static ProgressionLevelDefinition byLevel(int level) =>
      levels.firstWhere((definition) => definition.level == level);

  static int requiredLevelForRoom(String roomId) => levels
      .firstWhere((definition) => definition.unlockedRoomIds.contains(roomId))
      .level;
}
