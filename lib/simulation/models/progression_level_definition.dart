import 'ghost.dart';

class ProgressionLevelDefinition {
  const ProgressionLevelDefinition({
    required this.level,
    required this.requiredExperience,
    this.unlockedGhostKinds = const {},
    this.unlockedRoomIds = const {},
  });

  final int level;
  final int requiredExperience;
  final Set<GhostKind> unlockedGhostKinds;
  final Set<String> unlockedRoomIds;
}
