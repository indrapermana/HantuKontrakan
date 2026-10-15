import 'package:flutter/material.dart';

import '../../application/game_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/game_panel.dart';

class AudioSettingsDialog extends StatefulWidget {
  const AudioSettingsDialog({required this.controller, super.key});

  final GameController controller;

  @override
  State<AudioSettingsDialog> createState() => _AudioSettingsDialogState();
}

class _AudioSettingsDialogState extends State<AudioSettingsDialog> {
  late bool musicMuted;
  late bool soundMuted;
  late double musicVolume;
  late double soundVolume;
  late bool hapticsEnabled;
  late bool reducedMotionEnabled;
  late bool analyticsConsentGranted;
  late bool errorReportingConsentGranted;
  bool privacyOptionsRequired = false;

  @override
  void initState() {
    super.initState();
    final state = widget.controller.state;
    musicMuted = state.musicMuted;
    soundMuted = state.soundMuted;
    musicVolume = state.musicVolume;
    soundVolume = state.soundVolume;
    hapticsEnabled = state.hapticsEnabled;
    reducedMotionEnabled = state.reducedMotionEnabled;
    analyticsConsentGranted = state.analyticsConsentGranted;
    errorReportingConsentGranted = state.errorReportingConsentGranted;
    _loadPrivacyOptionsStatus();
  }

  Future<void> _loadPrivacyOptionsStatus() async {
    final required = await widget.controller.isPrivacyOptionsRequired();
    if (mounted) setState(() => privacyOptionsRequired = required);
  }

  Future<void> _save() => widget.controller.setAudioPreferences(
    musicMuted: musicMuted,
    soundMuted: soundMuted,
    musicVolume: musicVolume,
    soundVolume: soundVolume,
  );

  Future<void> _saveFeedback() => widget.controller.setFeedbackPreferences(
    hapticsEnabled: hapticsEnabled,
    reducedMotionEnabled: reducedMotionEnabled,
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return GameDialog(
      title: strings.settingsTitle,
      icon: Icons.settings_rounded,
      // ignore: sort_child_properties_last
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                strings.audioSettingsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SwitchListTile(
              key: const Key('music-muted'),
              title: Text(strings.musicMutedLabel),
              value: musicMuted,
              onChanged: (value) {
                setState(() => musicMuted = value);
                _save();
              },
            ),
            Text(strings.musicVolumeLabel),
            Slider(
              key: const Key('music-volume'),
              value: musicVolume,
              divisions: 10,
              label: '${(musicVolume * 100).round()}%',
              onChanged: (value) => setState(() => musicVolume = value),
              onChangeEnd: (_) => _save(),
            ),
            SwitchListTile(
              key: const Key('sound-muted'),
              title: Text(strings.soundMutedLabel),
              value: soundMuted,
              onChanged: (value) {
                setState(() => soundMuted = value);
                _save();
              },
            ),
            Text(strings.soundVolumeLabel),
            Slider(
              key: const Key('sound-volume'),
              value: soundVolume,
              divisions: 10,
              label: '${(soundVolume * 100).round()}%',
              onChanged: (value) => setState(() => soundVolume = value),
              onChangeEnd: (_) => _save(),
            ),
            const Divider(),
            ExpansionTile(
              key: const Key('privacy-settings-section'),
              tilePadding: EdgeInsets.zero,
              title: Text(strings.privacySettingsTitle),
              children: [
                Text(strings.privacyOfflineExplanation),
                TextButton(
                  key: const Key('privacy-policy'),
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (dialogContext) => GameDialog(
                      title: strings.privacyPolicyTitle,
                      icon: Icons.privacy_tip_rounded,
                      // ignore: sort_child_properties_last
                      child: SingleChildScrollView(
                        child: Text(strings.privacyPolicyBody),
                      ),
                      primaryAction: GamePrimaryButton(
                        label: strings.closeLabel,
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                  ),
                  child: Text(strings.privacyPolicyLabel),
                ),
                SwitchListTile(
                  key: const Key('analytics-consent'),
                  title: Text(strings.analyticsConsentLabel),
                  value: analyticsConsentGranted,
                  onChanged: (value) {
                    setState(() => analyticsConsentGranted = value);
                    widget.controller.setAnalyticsConsent(value);
                  },
                ),
                SwitchListTile(
                  key: const Key('error-reporting-consent'),
                  title: Text(strings.errorReportingConsentLabel),
                  value: errorReportingConsentGranted,
                  onChanged: (value) {
                    setState(() => errorReportingConsentGranted = value);
                    widget.controller.setErrorReportingConsent(value);
                  },
                ),
                if (privacyOptionsRequired)
                  OutlinedButton(
                    key: const Key('ad-privacy-options'),
                    onPressed: widget.controller.showPrivacyOptions,
                    child: Text(strings.adPrivacyOptionsLabel),
                  ),
              ],
            ),
            SwitchListTile(
              key: const Key('haptics-enabled'),
              title: Text(strings.hapticsLabel),
              subtitle: Text(strings.hapticsDescription),
              value: hapticsEnabled,
              onChanged: (value) {
                setState(() => hapticsEnabled = value);
                _saveFeedback();
              },
            ),
            SwitchListTile(
              key: const Key('reduced-motion-enabled'),
              title: Text(strings.reducedMotionLabel),
              subtitle: Text(strings.reducedMotionDescription),
              value: reducedMotionEnabled,
              onChanged: (value) {
                setState(() => reducedMotionEnabled = value);
                _saveFeedback();
              },
            ),
          ],
        ),
      ),
      primaryAction: GamePrimaryButton(
        label: strings.closeLabel,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
