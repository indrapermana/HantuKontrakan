import 'ghost.dart';

class IncidentDefinition {
  const IncidentDefinition({
    required this.id,
    this.requiredGhostKind,
    this.maximumGhostHappiness,
    this.minimumChaos,
    this.minimumPlayerLevel,
  });

  final String id;
  final GhostKind? requiredGhostKind;
  final int? maximumGhostHappiness;
  final int? minimumChaos;
  final int? minimumPlayerLevel;
}
