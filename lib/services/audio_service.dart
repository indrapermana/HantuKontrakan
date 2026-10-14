import 'package:audioplayers/audioplayers.dart';

import '../game/assets/game_assets.dart';

enum AudioCue { coin, upgrade, unlock, incident, repair, ghost }

class AudioPreferences {
  const AudioPreferences({
    required this.musicMuted,
    required this.soundMuted,
    required this.musicVolume,
    required this.soundVolume,
  });

  final bool musicMuted;
  final bool soundMuted;
  final double musicVolume;
  final double soundVolume;
}

abstract interface class AudioService {
  Future<void> initialize(AudioPreferences preferences);
  Future<void> updatePreferences(AudioPreferences preferences);
  Future<void> resumeBackground();
  Future<void> pauseBackground();
  Future<void> play(AudioCue cue);
  Future<void> dispose();
}

class NoopAudioService implements AudioService {
  const NoopAudioService();

  @override
  Future<void> initialize(AudioPreferences preferences) async {}

  @override
  Future<void> updatePreferences(AudioPreferences preferences) async {}

  @override
  Future<void> resumeBackground() async {}

  @override
  Future<void> pauseBackground() async {}

  @override
  Future<void> play(AudioCue cue) async {}

  @override
  Future<void> dispose() async {}
}

class AudioplayersAudioService implements AudioService {
  AudioplayersAudioService({
    AudioPlayer? musicPlayer,
    AudioPlayer? effectsPlayer,
  }) : _musicPlayer = musicPlayer ?? AudioPlayer(),
       _effectsPlayer = effectsPlayer ?? AudioPlayer();

  final AudioPlayer _musicPlayer;
  final AudioPlayer _effectsPlayer;
  late AudioPreferences _preferences;
  bool _initialized = false;
  bool _backgroundStarted = false;

  static const Map<AudioCue, String> _effectAssets = {
    AudioCue.coin: 'audio/sfx/coin_collect.wav',
    AudioCue.upgrade: 'audio/sfx/room_upgrade.wav',
    AudioCue.unlock: 'audio/sfx/room_unlock.wav',
    AudioCue.incident: 'audio/sfx/event_alert.wav',
    AudioCue.repair: 'audio/sfx/repair.wav',
    AudioCue.ghost: 'audio/sfx/ghost_appear.wav',
  };

  @override
  Future<void> initialize(AudioPreferences preferences) async {
    _preferences = preferences;
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    _initialized = true;
    await resumeBackground();
  }

  @override
  Future<void> updatePreferences(AudioPreferences preferences) async {
    _preferences = preferences;
    if (!_initialized) return;
    await _musicPlayer.setVolume(
      preferences.musicMuted ? 0 : preferences.musicVolume,
    );
  }

  @override
  Future<void> resumeBackground() async {
    if (!_initialized) return;
    final volume = _preferences.musicMuted ? 0.0 : _preferences.musicVolume;
    if (_backgroundStarted) {
      await _musicPlayer.setVolume(volume);
      await _musicPlayer.resume();
      return;
    }
    _backgroundStarted = true;
    await _musicPlayer.play(
      AssetSource(GameAssets.backgroundMusic),
      volume: volume,
    );
  }

  @override
  Future<void> pauseBackground() async {
    if (_backgroundStarted) await _musicPlayer.pause();
  }

  @override
  Future<void> play(AudioCue cue) async {
    if (!_initialized || _preferences.soundMuted) return;
    await _effectsPlayer.play(
      AssetSource(_effectAssets[cue]!),
      volume: _preferences.soundVolume,
      mode: PlayerMode.lowLatency,
    );
  }

  @override
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _effectsPlayer.dispose();
  }
}
