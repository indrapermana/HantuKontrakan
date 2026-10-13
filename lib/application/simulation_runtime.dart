import 'dart:math';

abstract interface class GameClock {
  DateTime now();
}

class SystemGameClock implements GameClock {
  const SystemGameClock();

  @override
  DateTime now() => DateTime.now();
}

class SeededRandomSource {
  SeededRandomSource(this.seed) : _random = Random(seed);

  final int seed;
  Random _random;

  double nextDouble() => _random.nextDouble();

  void reset() {
    _random = Random(seed);
  }
}
