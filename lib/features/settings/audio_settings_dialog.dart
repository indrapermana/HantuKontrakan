import 'package:flutter/material.dart';

import '../../application/game_controller.dart';
import '../../l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    final state = widget.controller.state;
    musicMuted = state.musicMuted;
    soundMuted = state.soundMuted;
    musicVolume = state.musicVolume;
    soundVolume = state.soundVolume;
  }

  Future<void> _save() => widget.controller.setAudioPreferences(
    musicMuted: musicMuted,
    soundMuted: soundMuted,
    musicVolume: musicVolume,
    soundVolume: soundVolume,
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(strings.audioSettingsTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.closeLabel),
        ),
      ],
    );
  }
}
