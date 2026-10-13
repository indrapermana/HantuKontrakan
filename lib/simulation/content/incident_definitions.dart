import '../models/ghost.dart';
import '../models/incident_definition.dart';

abstract final class IncidentDefinitions {
  // HK-017 contains scheduler metadata only. Localized copy, choices, and
  // outcomes belong to HK-018 and HK-019.
  static const List<IncidentDefinition> schedulerPool = [
    IncidentDefinition(id: 'electricity_outage'),
    IncidentDefinition(
      id: 'pocong_midnight_exercise',
      requiredGhostKind: GhostKind.pocong,
      maximumGhostHappiness: 39,
    ),
    IncidentDefinition(
      id: 'tuyul_missing_sandals',
      requiredGhostKind: GhostKind.tuyul,
    ),
    IncidentDefinition(id: 'pak_rt_complaint', minimumChaos: 70),
  ];
}
