import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

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

  static final Uint8List _backgroundBytes = _tone(
    frequencies: const [110, 164.81, 220],
    durationSeconds: 2,
    amplitude: 0.14,
  );
  static final Map<AudioCue, Uint8List> _effectBytes = {
    AudioCue.coin: _tone(frequencies: const [880, 1320], durationSeconds: 0.12),
    AudioCue.upgrade: _tone(
      frequencies: const [440, 660],
      durationSeconds: 0.18,
    ),
    AudioCue.unlock: _tone(
      frequencies: const [523.25, 783.99],
      durationSeconds: 0.24,
    ),
    AudioCue.incident: _tone(
      frequencies: const [196, 185],
      durationSeconds: 0.28,
    ),
    AudioCue.repair: _tone(
      frequencies: const [330, 247],
      durationSeconds: 0.16,
    ),
    AudioCue.ghost: _tone(
      frequencies: const [293.66, 349.23],
      durationSeconds: 0.14,
    ),
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
      BytesSource(_backgroundBytes, mimeType: 'audio/wav'),
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
      BytesSource(_effectBytes[cue]!, mimeType: 'audio/wav'),
      volume: _preferences.soundVolume,
      mode: PlayerMode.lowLatency,
    );
  }

  @override
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _effectsPlayer.dispose();
  }

  static Uint8List _tone({
    required List<double> frequencies,
    required double durationSeconds,
    double amplitude = 0.28,
  }) {
    const sampleRate = 11025;
    const bytesPerSample = 2;
    final sampleCount = (sampleRate * durationSeconds).round();
    final dataSize = sampleCount * bytesPerSample;
    final bytes = ByteData(44 + dataSize);
    void text(int offset, String value) {
      for (var index = 0; index < value.length; index++) {
        bytes.setUint8(offset + index, value.codeUnitAt(index));
      }
    }

    text(0, 'RIFF');
    bytes.setUint32(4, 36 + dataSize, Endian.little);
    text(8, 'WAVE');
    text(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * bytesPerSample, Endian.little);
    bytes.setUint16(32, bytesPerSample, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    text(36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);

    for (var sample = 0; sample < sampleCount; sample++) {
      final time = sample / sampleRate;
      final edge = math.min(sample, sampleCount - sample - 1);
      final envelope = math.min(1.0, edge / (sampleRate * 0.02));
      var value = 0.0;
      for (final frequency in frequencies) {
        value += math.sin(2 * math.pi * frequency * time);
      }
      value = value / frequencies.length * amplitude * envelope;
      bytes.setInt16(
        44 + sample * bytesPerSample,
        (value * 32767).round(),
        Endian.little,
      );
    }
    return bytes.buffer.asUint8List();
  }
}
