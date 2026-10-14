import 'package:flutter/material.dart';

import '../../application/game_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../simulation/content/mission_definitions.dart';
import '../../simulation/models/mission_definition.dart';
import '../../simulation/systems/mission_system.dart';
import '../../widgets/game_panel.dart';

class MissionDialog extends StatelessWidget {
  const MissionDialog({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final strings = AppLocalizations.of(context);
      final state = controller.state;
      return GameDialog(
        title: strings.missionsTitle,
        icon: Icons.emoji_events_rounded,
        // ignore: sort_child_properties_last
        child: SizedBox(
          width: 420,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: MissionDefinitions.all.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final mission = MissionDefinitions.all[index];
              final claimed = state.completedMissionIds.contains(mission.id);
              final claimable = MissionSystem.isClaimable(state, mission);
              return Card(
                color: gamePanelWood.withValues(alpha: 0.72),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _localized(context, mission.title),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(_localized(context, mission.description)),
                      const SizedBox(height: 8),
                      Text(
                        strings.missionRewardSummary(
                          mission.reward.coins,
                          mission.reward.experience,
                          mission.reward.mysticalCrystals,
                        ),
                        style: const TextStyle(color: gamePanelGold),
                      ),
                      const SizedBox(height: 10),
                      GamePrimaryButton(
                        key: Key('claim-mission-${mission.id}'),
                        onPressed: claimable
                            ? () => controller.claimMissionReward(mission.id)
                            : null,
                        label: claimed
                            ? strings.missionClaimed
                            : claimable
                            ? strings.missionClaim
                            : strings.missionInProgress,
                        icon: claimed
                            ? Icons.check_rounded
                            : Icons.card_giftcard_rounded,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        primaryAction: GamePrimaryButton(
          label: strings.continueLabel,
          onPressed: () => Navigator.pop(context),
        ),
      );
    },
  );

  String _localized(BuildContext context, LocalizedMissionText text) =>
      Localizations.localeOf(context).languageCode == 'id' ? text.id : text.en;
}
