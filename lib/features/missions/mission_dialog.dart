import 'package:flutter/material.dart';

import '../../application/game_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../simulation/content/mission_definitions.dart';
import '../../simulation/models/mission_definition.dart';
import '../../simulation/models/daily_goal_definition.dart';
import '../../simulation/systems/daily_goal_system.dart';
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
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                strings.dailyGoalsTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: gamePanelGold,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(strings.dailyGoalsSubtitle),
              if (state.dailyGoalDayKey != null) ...[
                const SizedBox(height: 4),
                Text(
                  strings.dailyScheduleLabel(state.dailyGoalDayKey!),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
              const SizedBox(height: 10),
              for (final goal in controller.dailyGoals) ...[
                _DailyGoalCard(controller: controller, goal: goal),
                const SizedBox(height: 8),
              ],
              _DailyChestCard(controller: controller),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(),
              ),
              Text(
                strings.chapterOneTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: gamePanelGold,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              for (final mission in MissionDefinitions.all) ...[
                _ChapterMissionCard(controller: controller, mission: mission),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        primaryAction: GamePrimaryButton(
          label: strings.continueLabel,
          onPressed: () => Navigator.pop(context),
        ),
      );
    },
  );
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.controller, required this.goal});

  final GameController controller;
  final DailyGoalDefinition goal;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final state = controller.state;
    final progress = DailyGoalSystem.progressFor(state, goal);
    final claimed = state.completedDailyGoalIds.contains(goal.id);
    final claimable = DailyGoalSystem.isClaimable(state, goal);
    return Card(
      key: Key('daily-goal-${goal.id}'),
      color: gamePanelWood.withValues(alpha: 0.72),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _localizedText(context, goal.title),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (goal.kind == DailyGoalKind.tenantRequest)
                  Chip(label: Text(strings.dailyTenantRequest)),
              ],
            ),
            const SizedBox(height: 4),
            Text(_localizedText(context, goal.description)),
            const SizedBox(height: 8),
            Semantics(
              label: strings.dailyGoalProgress(progress, goal.target),
              child: LinearProgressIndicator(
                value: progress / goal.target,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: gamePanelGold,
                backgroundColor: Colors.black26,
              ),
            ),
            const SizedBox(height: 5),
            Text(strings.dailyGoalProgress(progress, goal.target)),
            const SizedBox(height: 5),
            Text(
              strings.missionRewardSummary(
                goal.reward.coins,
                goal.reward.experience,
                goal.reward.mysticalCrystals,
              ),
              style: const TextStyle(color: gamePanelGold),
            ),
            const SizedBox(height: 8),
            if (claimable)
              GamePrimaryButton(
                key: Key('claim-daily-goal-${goal.id}'),
                onPressed: () => controller.claimDailyGoal(goal.id),
                label: strings.missionClaim,
                icon: Icons.card_giftcard_rounded,
              )
            else
              Row(
                children: [
                  Icon(
                    claimed ? Icons.check_circle_rounded : Icons.schedule,
                    size: 19,
                    color: claimed ? gamePanelGreen : Colors.white54,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    claimed
                        ? strings.missionClaimed
                        : strings.missionInProgress,
                    style: TextStyle(
                      color: claimed ? gamePanelGreen : Colors.white54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DailyChestCard extends StatelessWidget {
  const _DailyChestCard({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final state = controller.state;
    final claimable = DailyGoalSystem.isChestClaimable(state);
    return Card(
      key: const Key('daily-reward-chest'),
      color: gamePanelGold.withValues(alpha: 0.17),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.dailyChestTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: gamePanelGold,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(strings.dailyChestDescription),
            const SizedBox(height: 6),
            Text(
              strings.missionRewardSummary(
                DailyGoalSystem.chestReward.coins,
                DailyGoalSystem.chestReward.experience,
                DailyGoalSystem.chestReward.mysticalCrystals,
              ),
              style: const TextStyle(color: gamePanelGold),
            ),
            const SizedBox(height: 10),
            GamePrimaryButton(
              key: const Key('claim-daily-chest'),
              onPressed: claimable ? controller.claimDailyChest : null,
              label: state.dailyChestClaimed
                  ? strings.dailyChestClaimed
                  : claimable
                  ? strings.dailyChestClaim
                  : strings.dailyChestLocked,
              icon: state.dailyChestClaimed
                  ? Icons.check_rounded
                  : Icons.redeem_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterMissionCard extends StatelessWidget {
  const _ChapterMissionCard({required this.controller, required this.mission});

  final GameController controller;
  final MissionDefinition mission;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final state = controller.state;
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
              _localizedText(context, mission.title),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(_localizedText(context, mission.description)),
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
              icon: claimed ? Icons.check_rounded : Icons.card_giftcard_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

String _localizedText(BuildContext context, LocalizedMissionText text) =>
    Localizations.localeOf(context).languageCode == 'id' ? text.id : text.en;
