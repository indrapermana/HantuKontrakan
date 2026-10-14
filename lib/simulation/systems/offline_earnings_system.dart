import '../constants/game_balance.dart';
import '../models/game_state.dart';
import 'rent_system.dart';

abstract final class OfflineEarningsSystem {
  static GameState pause(GameState state, int timestampMillis) {
    if (state.offlineRateSnapshotMicrocoinsPerMinute != null) return state;
    return state.copyWith(
      offlineRateSnapshotMicrocoinsPerMinute:
          RentSystem.totalRentPerMinuteMicrocoins(state),
      lastOfflineAccrualTimestampMillis: timestampMillis,
    );
  }

  static GameState resume(GameState state, int timestampMillis) {
    final rate = state.offlineRateSnapshotMicrocoinsPerMinute;
    final pausedAt = state.lastOfflineAccrualTimestampMillis;
    if (rate == null || pausedAt == null) return state;

    final elapsedMillis = timestampMillis - pausedAt;
    final cappedElapsedMillis = elapsedMillis.clamp(
      0,
      GameBalance.maximumOfflineMinutes * GameBalance.millisecondsPerMinute,
    );
    final earnedMicrocoins =
        rate *
        cappedElapsedMillis *
        GameBalance.offlineEarningsPercent ~/
        (GameBalance.millisecondsPerMinute * 100);

    return state.copyWith(
      pendingRentMicrocoinsByRoom: RentSystem.distributeMicrocoinsByRoom(
        state,
        earnedMicrocoins,
      ),
      offlineRateSnapshotMicrocoinsPerMinute: null,
      lastOfflineAccrualTimestampMillis: timestampMillis,
    );
  }
}
