import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/application/simulation_runtime.dart';

void main() {
  test('equal seeds produce equal random sequences and reset repeats them', () {
    final first = SeededRandomSource(42);
    final second = SeededRandomSource(42);

    final sequence = List.generate(4, (_) => first.nextDouble());
    expect(List.generate(4, (_) => second.nextDouble()), sequence);

    first.reset();
    expect(List.generate(4, (_) => first.nextDouble()), sequence);
  });
}
