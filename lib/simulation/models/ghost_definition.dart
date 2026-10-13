import 'ghost.dart';

class GhostDefinition {
  const GhostDefinition({
    required this.kind,
    required this.baseRentPerMinute,
    required this.unlockLevel,
    required this.chaosPerTenMinutes,
    required this.preferredRoomTags,
    required this.positiveNeighbor,
    required this.dislikedNeighbor,
    required this.abilityId,
  });

  final GhostKind kind;
  final int baseRentPerMinute;
  final int unlockLevel;
  final int chaosPerTenMinutes;
  final List<String> preferredRoomTags;
  final GhostKind positiveNeighbor;
  final GhostKind dislikedNeighbor;
  final String abilityId;
}
