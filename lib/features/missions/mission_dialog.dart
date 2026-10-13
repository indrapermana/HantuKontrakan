import 'package:flutter/material.dart';

import '../../application/game_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../simulation/content/mission_definitions.dart';
import '../../simulation/models/mission_definition.dart';
import '../../simulation/systems/mission_system.dart';

class MissionDialog extends StatelessWidget {
  const MissionDialog({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final strings = AppLocalizations.of(context);
      final state = controller.state;
      return AlertDialog(
        title: Text(strings.missionsTitle),
        content: SizedBox(
          width: 420,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: MissionDefinitions.all.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final mission = MissionDefinitions.all[index];
              final claimed = state.completedMissionIds.contains(mission.id);
              final claimable = MissionSystem.isClaimable(state, mission);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_localized(context, mission.title)),
                subtitle: Text(
                  '${_localized(context, mission.description)}\n'
                  '${strings.missionRewardSummary(mission.reward.coins, mission.reward.experience, mission.reward.mysticalCrystals)}',
                ),
                trailing: FilledButton.tonal(
                  key: Key('claim-mission-${mission.id}'),
                  onPressed: claimable
                      ? () => controller.claimMissionReward(mission.id)
                      : null,
                  child: Text(
                    claimed
                        ? strings.missionClaimed
                        : claimable
                        ? strings.missionClaim
                        : strings.missionInProgress,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.continueLabel),
          ),
        ],
      );
    },
  );

  String _localized(BuildContext context, LocalizedMissionText text) =>
      Localizations.localeOf(context).languageCode == 'id' ? text.id : text.en;
}
