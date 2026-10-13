import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/constants/game_balance.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/systems/offline_earnings_system.dart';
import 'package:hantu_kontrakan/simulation/systems/rent_system.dart';

void main() {
  const minute = GameBalance.millisecondsPerMinute;

  test('pause snapshots the current total rate once', () {
    final state = GameState.seeded();
    final paused = OfflineEarningsSystem.pause(state, 1000);
    final repeated = OfflineEarningsSystem.pause(paused, 2000);

    expect(
      paused.offlineRateSnapshotMicrocoinsPerMinute,
      RentSystem.totalRentPerMinuteMicrocoins(state),
    );
    expect(paused.lastOfflineAccrualTimestampMillis, 1000);
    expect(identical(repeated, paused), isTrue);
  });

  test('two hours at 40 coins per minute earns 2400 coins', () {
    final paused = GameState.seeded().copyWith(
      offlineRateSnapshotMicrocoinsPerMinute:
          40 * GameBalance.microcoinsPerCoin,
      lastOfflineAccrualTimestampMillis: 1000,
    );

    final resumed = OfflineEarningsSystem.resume(paused, 1000 + (120 * minute));

    expect(resumed.pendingRentMicrocoins, 2400 * GameBalance.microcoinsPerCoin);
    expect(resumed.offlineRateSnapshotMicrocoinsPerMinute, isNull);
    expect(resumed.lastOfflineAccrualTimestampMillis, 1000 + (120 * minute));
  });

  test('five hours earns only the four-hour cap', () {
    final paused = GameState.seeded().copyWith(
      offlineRateSnapshotMicrocoinsPerMinute:
          40 * GameBalance.microcoinsPerCoin,
      lastOfflineAccrualTimestampMillis: 0,
    );

    final resumed = OfflineEarningsSystem.resume(paused, 300 * minute);

    expect(resumed.pendingRentMicrocoins, 4800 * GameBalance.microcoinsPerCoin);
  });

  test('resume consumes snapshot once and repeated resume cannot credit', () {
    final paused = GameState.seeded().copyWith(
      offlineRateSnapshotMicrocoinsPerMinute:
          40 * GameBalance.microcoinsPerCoin,
      lastOfflineAccrualTimestampMillis: 0,
    );
    final first = OfflineEarningsSystem.resume(paused, 60 * minute);
    final repeated = OfflineEarningsSystem.resume(first, 120 * minute);

    expect(first.pendingRentMicrocoins, 1200 * GameBalance.microcoinsPerCoin);
    expect(identical(repeated, first), isTrue);
  });

  test('clock rollback yields zero and still consumes the snapshot', () {
    final paused = GameState.seeded().copyWith(
      pendingRentMicrocoins: 123,
      offlineRateSnapshotMicrocoinsPerMinute:
          40 * GameBalance.microcoinsPerCoin,
      lastOfflineAccrualTimestampMillis: 2000,
    );

    final resumed = OfflineEarningsSystem.resume(paused, 1000);

    expect(resumed.pendingRentMicrocoins, 123);
    expect(resumed.offlineRateSnapshotMicrocoinsPerMinute, isNull);
    expect(resumed.lastOfflineAccrualTimestampMillis, 1000);
  });
}
