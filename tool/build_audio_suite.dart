import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const _sampleRate = 32000;
const _crossfadeSeconds = 2;

void main() {
  final cozy = _readPcm16('assets/audio/music/cozy_night_loop.wav');
  final busy = _readPcm16('assets/audio/music/haunted_hustle_loop.wav');
  final mystery = _readPcm16('assets/audio/music/malam_jumat_mischief.wav');
  final movements = <({List<int> samples, double offset})>[
    (samples: cozy, offset: 0),
    (samples: busy, offset: 5.5),
    (samples: mystery, offset: 10.4),
    (samples: cozy, offset: 9.6),
    (samples: mystery, offset: 0),
    (samples: busy, offset: 11),
    (samples: cozy, offset: 4.8),
    (samples: busy, offset: 0),
    (samples: mystery, offset: 5.2),
  ];
  var suite = <int>[];
  for (final movement in movements) {
    final rotated = _rotate(movement.samples, movement.offset);
    suite = suite.isEmpty ? rotated : _crossfade(suite, rotated);
  }
  suite = _fadeIn(suite, const Duration(seconds: 2));
  suite = _fadeOut(suite, const Duration(seconds: 2))
    ..addAll(List<int>.filled(_sampleRate ~/ 4, 0));
  _writePcm16('assets/audio/music/horror_comedy_night_suite.wav', suite);
  stdout.writeln(
    'Built ${(suite.length / _sampleRate).toStringAsFixed(2)}s night suite.',
  );
}

List<int> _readPcm16(String path) {
  final bytes = File(path).readAsBytesSync();
  final data = ByteData.sublistView(bytes);
  if (bytes.length < 44 ||
      String.fromCharCodes(bytes.sublist(0, 4)) != 'RIFF' ||
      data.getUint16(20, Endian.little) != 1 ||
      data.getUint16(22, Endian.little) != 1 ||
      data.getUint32(24, Endian.little) != _sampleRate ||
      data.getUint16(34, Endian.little) != 16) {
    throw FormatException('$path must be mono 32kHz PCM16 WAV.');
  }
  var offset = 12;
  while (offset + 8 <= bytes.length) {
    final id = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final length = data.getUint32(offset + 4, Endian.little);
    if (id == 'data') {
      return [
        for (var i = offset + 8; i < offset + 8 + length; i += 2)
          data.getInt16(i, Endian.little),
      ];
    }
    offset += 8 + length + (length.isOdd ? 1 : 0);
  }
  throw FormatException('$path has no PCM data chunk.');
}

List<int> _rotate(List<int> samples, double seconds) {
  final offset = (seconds * _sampleRate).round() % samples.length;
  return [...samples.skip(offset), ...samples.take(offset)];
}

List<int> _crossfade(List<int> left, List<int> right) {
  final count = min(
    _crossfadeSeconds * _sampleRate,
    min(left.length, right.length),
  );
  final result = left.sublist(0, left.length - count);
  for (var i = 0; i < count; i += 1) {
    final mix = i / (count - 1);
    result.add(
      (left[left.length - count + i] * (1 - mix) + right[i] * mix)
          .round()
          .clamp(-32768, 32767),
    );
  }
  result.addAll(right.skip(count));
  return result;
}

List<int> _fadeOut(List<int> samples, Duration duration) {
  final result = samples.toList();
  final count = min(
    (duration.inMicroseconds * _sampleRate ~/ Duration.microsecondsPerSecond),
    result.length,
  );
  for (var i = 0; i < count; i += 1) {
    result[result.length - count + i] =
        (result[result.length - count + i] * (1 - (i / count))).round();
  }
  return result;
}

List<int> _fadeIn(List<int> samples, Duration duration) {
  final result = samples.toList();
  final count = min(
    (duration.inMicroseconds * _sampleRate ~/ Duration.microsecondsPerSecond),
    result.length,
  );
  for (var i = 0; i < count; i += 1) {
    result[i] = (result[i] * (i / count)).round();
  }
  return result;
}

void _writePcm16(String path, List<int> samples) {
  final dataLength = samples.length * 2;
  final bytes = Uint8List(44 + dataLength);
  final data = ByteData.sublistView(bytes);
  bytes.setRange(0, 4, 'RIFF'.codeUnits);
  data.setUint32(4, 36 + dataLength, Endian.little);
  bytes.setRange(8, 12, 'WAVE'.codeUnits);
  bytes.setRange(12, 16, 'fmt '.codeUnits);
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, _sampleRate, Endian.little);
  data.setUint32(28, _sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  bytes.setRange(36, 40, 'data'.codeUnits);
  data.setUint32(40, dataLength, Endian.little);
  for (var i = 0; i < samples.length; i += 1) {
    data.setInt16(44 + (i * 2), samples[i], Endian.little);
  }
  File(path).writeAsBytesSync(bytes, flush: true);
}
