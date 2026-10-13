import 'ghost.dart';

class LocalizedIncidentText {
  const LocalizedIncidentText({required this.id, required this.en});

  final String id;
  final String en;
}

class IncidentEffects {
  const IncidentEffects({
    this.coinDelta = 0,
    this.happinessDeltaByKind = const {},
    this.chaosDelta = 0,
    this.reputationDelta = 0,
  });

  final int coinDelta;
  final Map<GhostKind, int> happinessDeltaByKind;
  final int chaosDelta;
  final int reputationDelta;
}

class IncidentChoiceDefinition {
  const IncidentChoiceDefinition({
    required this.id,
    required this.label,
    required this.effects,
    required this.response,
  });

  final String id;
  final LocalizedIncidentText label;
  final IncidentEffects effects;
  final LocalizedIncidentText response;
}

class IncidentDefinition {
  const IncidentDefinition({
    required this.id,
    this.title,
    this.dialogue,
    this.choices = const [],
    this.cooldownSeconds = 180,
    this.requiredGhostKind,
    this.maximumGhostHappiness,
    this.minimumGhostHappiness,
    this.minimumChaos,
    this.minimumPlayerLevel,
    this.minimumReputation,
    this.requiresOccupiedRoom = false,
    this.maximumResidentRoomDurabilityLevel,
  });

  final String id;
  final LocalizedIncidentText? title;
  final LocalizedIncidentText? dialogue;
  final List<IncidentChoiceDefinition> choices;
  final int cooldownSeconds;
  final GhostKind? requiredGhostKind;
  final int? maximumGhostHappiness;
  final int? minimumGhostHappiness;
  final int? minimumChaos;
  final int? minimumPlayerLevel;
  final int? minimumReputation;
  final bool requiresOccupiedRoom;
  final int? maximumResidentRoomDurabilityLevel;
}
