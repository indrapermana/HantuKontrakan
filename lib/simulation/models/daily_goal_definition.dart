import 'mission_definition.dart';

enum DailyGoalKind { collectRent, activeManagement, tenantRequest }

class DailyGoalDefinition {
  const DailyGoalDefinition({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.target,
    required this.reward,
    this.roomId,
  });

  final String id;
  final DailyGoalKind kind;
  final LocalizedMissionText title;
  final LocalizedMissionText description;
  final int target;
  final MissionReward reward;
  final String? roomId;
}
