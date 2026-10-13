import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../simulation/models/tutorial_step.dart';

class TutorialPanel extends StatelessWidget {
  const TutorialPanel({
    required this.step,
    required this.onContinue,
    required this.onPlacePocong,
    required this.onPlaceKuntilanak,
    super.key,
  });

  final TutorialStep step;
  final VoidCallback onContinue;
  final VoidCallback onPlacePocong;
  final VoidCallback onPlaceKuntilanak;

  @override
  Widget build(BuildContext context) {
    if (step == TutorialStep.completed) return const SizedBox.shrink();
    final strings = AppLocalizations.of(context);
    final (title, body, action, callback) = switch (step) {
      TutorialStep.openingStory => (
        strings.tutorialOpeningTitle,
        strings.tutorialOpeningBody,
        strings.continueLabel,
        onContinue,
      ),
      TutorialStep.placePocong => (
        strings.tutorialPlacePocongTitle,
        strings.tutorialPlacePocongBody,
        strings.tutorialPlacePocongAction,
        onPlacePocong,
      ),
      TutorialStep.collectFirstRent => (
        strings.tutorialCollectRentTitle,
        strings.tutorialCollectRentBody,
        null,
        null,
      ),
      TutorialStep.placeKuntilanak => (
        strings.tutorialKuntilanakTitle,
        strings.tutorialKuntilanakBody,
        strings.tutorialPlaceKuntilanakAction,
        onPlaceKuntilanak,
      ),
      TutorialStep.resolveScriptedIncident => (
        strings.tutorialIncidentTitle,
        strings.tutorialIncidentBody,
        null,
        null,
      ),
      TutorialStep.inspectLockedRoom => (
        strings.tutorialLockedRoomTitle,
        strings.tutorialLockedRoomBody,
        strings.tutorialFinish,
        onContinue,
      ),
      TutorialStep.completed => throw StateError('Handled above.'),
    };
    return Card(
      key: const Key('tutorial-panel'),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.auto_stories),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(body),
                ],
              ),
            ),
            if (action != null && callback != null) ...[
              const SizedBox(width: 8),
              FilledButton(
                key: Key('tutorial-${step.name}-action'),
                onPressed: callback,
                child: Text(action),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
