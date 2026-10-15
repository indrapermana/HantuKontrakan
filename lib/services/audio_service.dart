import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

import '../game/assets/game_assets.dart';

enum AudioCue {
  coin,
  upgrade,
  unlock,
  incidentAlert,
  incidentGood,
  incidentBad,
  repair,
  pocong,
  pocongHappy,
  kuntilanak,
  kuntilanakHappy,
  tuyul,
  tuyulHappy,
  genderuwo,
  genderuwoHappy,
  ghostAngry,
  furniture,
  reward,
  uiClick,
  unavailable,
}

enum AudioScene { calm, tension }

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
  Future<void> setScene(AudioScene scene);
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
  Future<void> setScene(AudioScene scene) async {}

  @override
  Future<void> dispose() async {}
}

class AudioplayersAudioService implements AudioService {
  AudioplayersAudioService({
    AudioPlayer? musicPlayer,
    AudioPlayer? effectsPlayer,
    AudioPlayer? tensionPlayer,
    AudioPlayer? ambiencePlayer,
    Random? random,
  }) : _musicPlayer = musicPlayer ?? AudioPlayer(),
       _effectsPlayer = effectsPlayer ?? AudioPlayer(),
       _tensionPlayer = tensionPlayer ?? AudioPlayer(),
       _ambiencePlayer = ambiencePlayer ?? AudioPlayer(),
       _random = random ?? Random();

  final AudioPlayer _musicPlayer;
  final AudioPlayer _effectsPlayer;
  final AudioPlayer _tensionPlayer;
  final AudioPlayer _ambiencePlayer;
  final Random _random;
  late AudioPreferences _preferences;
  bool _initialized = false;
  bool _backgroundStarted = false;
  bool _tensionStarted = false;
  bool _backgroundPaused = false;
  AudioScene _scene = AudioScene.calm;
  Timer? _ambienceTimer;

  static const Map<AudioCue, String> _effectAssets = {
    AudioCue.coin: 'audio/sfx/rent_collect_jingle.wav',
    AudioCue.upgrade: 'audio/sfx/upgrade_hammer_pop.wav',
    AudioCue.unlock: 'audio/sfx/room_unlock_magic.wav',
    AudioCue.incidentAlert: 'audio/sfx/incident_alert_comedy.wav',
    AudioCue.incidentGood: 'audio/sfx/incident_choice_good.wav',
    AudioCue.incidentBad: 'audio/sfx/incident_choice_bad.wav',
    AudioCue.repair: 'audio/sfx/repair_tap_tap.wav',
    AudioCue.pocong: 'audio/sfx/ghost_pocong_hop.wav',
    AudioCue.pocongHappy: 'audio/sfx/ghost_pocong_happy.wav',
    AudioCue.kuntilanak: 'audio/sfx/ghost_kuntilanak_complaint.wav',
    AudioCue.kuntilanakHappy: 'audio/sfx/ghost_kuntilanak_giggle.wav',
    AudioCue.tuyul: 'audio/sfx/ghost_tuyul_sneak.wav',
    AudioCue.tuyulHappy: 'audio/sfx/ghost_tuyul_prank.wav',
    AudioCue.genderuwo: 'audio/sfx/ghost_genderuwo_step.wav',
    AudioCue.genderuwoHappy: 'audio/sfx/ghost_genderuwo_chuckle.wav',
    AudioCue.ghostAngry: 'audio/sfx/ghost_general_angry.wav',
    AudioCue.furniture: 'audio/sfx/furniture_drop_bounce.wav',
    AudioCue.reward: 'audio/sfx/reward_big_fanfare.wav',
    AudioCue.uiClick: 'audio/sfx/ui_tap_bubble.wav',
    AudioCue.unavailable: 'audio/sfx/purchase_insufficient.wav',
  };

  @override
  Future<void> initialize(AudioPreferences preferences) async {
    _preferences = preferences;
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _tensionPlayer.setReleaseMode(ReleaseMode.loop);
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
    await _tensionPlayer.setVolume(_tensionVolume);
  }

  @override
  Future<void> resumeBackground() async {
    if (!_initialized) return;
    _backgroundPaused = false;
    final volume = _preferences.musicMuted ? 0.0 : _preferences.musicVolume;
    if (_backgroundStarted) {
      await _musicPlayer.setVolume(volume);
      await _musicPlayer.resume();
      if (_tensionStarted) await _tensionPlayer.resume();
      _scheduleAmbience();
      return;
    }
    _backgroundStarted = true;
    await _musicPlayer.play(
      AssetSource(GameAssets.backgroundMusic),
      volume: volume,
    );
    _scheduleAmbience();
  }

  @override
  Future<void> pauseBackground() async {
    _backgroundPaused = true;
    _ambienceTimer?.cancel();
    if (_backgroundStarted) await _musicPlayer.pause();
    if (_tensionStarted) await _tensionPlayer.pause();
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
  Future<void> setScene(AudioScene scene) async {
    if (!_initialized || scene == _scene) return;
    _scene = scene;
    if (scene == AudioScene.tension) {
      if (_tensionStarted) {
        await _tensionPlayer.setVolume(_tensionVolume);
        if (!_backgroundPaused) await _tensionPlayer.resume();
      } else {
        _tensionStarted = true;
        await _tensionPlayer.play(
          AssetSource(GameAssets.tensionMusic),
          volume: _tensionVolume,
        );
        if (_backgroundPaused) await _tensionPlayer.pause();
      }
    } else if (_tensionStarted) {
      await _tensionPlayer.setVolume(0);
    }
  }

  double get _tensionVolume =>
      _preferences.musicMuted || _scene != AudioScene.tension
      ? 0
      : (_preferences.musicVolume * 0.28).clamp(0, 1);

  void _scheduleAmbience() {
    _ambienceTimer?.cancel();
    if (_backgroundPaused || !_initialized) return;
    _ambienceTimer = Timer(Duration(seconds: 24 + _random.nextInt(28)), () {
      if (!_preferences.soundMuted && !_backgroundPaused) {
        unawaited(
          _ambiencePlayer.play(
            AssetSource(
              _random.nextBool()
                  ? 'audio/sfx/ambient_cricket_chirp.wav'
                  : 'audio/sfx/ambient_spooky_breeze.wav',
            ),
            volume: (_preferences.soundVolume * 0.24).clamp(0, 1),
            mode: PlayerMode.lowLatency,
          ),
        );
      }
      _scheduleAmbience();
    });
  }

  @override
  Future<void> dispose() async {
    _ambienceTimer?.cancel();
    await _musicPlayer.dispose();
    await _effectsPlayer.dispose();
    await _tensionPlayer.dispose();
    await _ambiencePlayer.dispose();
  }
}
