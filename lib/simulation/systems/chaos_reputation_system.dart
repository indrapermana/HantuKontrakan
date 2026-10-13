import '../constants/game_balance.dart';
import '../content/ghost_definitions.dart';
import '../models/game_state.dart';

abstract final class ChaosReputationSystem {
  static GameState applyActiveTicks(
    GameState state,
    int previousActiveSeconds,
  ) {
    final previousTicks =
        previousActiveSeconds ~/ GameBalance.chaosIntervalSeconds;
    final currentTicks =
        state.activeSimulationSeconds ~/ GameBalance.chaosIntervalSeconds;
    final tickCount = currentTicks - previousTicks;
    if (tickCount <= 0) return state;

    final occupiedContribution = state.rooms
        .where((room) => room.occupantId != null)
        .fold(
          0,
          (sum, room) =>
              sum +
              GhostDefinitions.byKind(
                state.ghostById(room.occupantId!).kind,
              ).chaosPerTenMinutes,
        );
    final deltaPerTick =
        occupiedContribution - GameBalance.chaosNaturalReductionPerInterval;
    return state.copyWith(
      chaos: (state.chaos + deltaPerTick * tickCount).clamp(
        GameBalance.minimumChaos,
        GameBalance.maximumChaos,
      ),
    );
  }

  static GameState applyEventDeltas(
    GameState state, {
    int chaosDelta = 0,
    int reputationDelta = 0,
  }) {
    final chaos = (state.chaos + chaosDelta).clamp(
      GameBalance.minimumChaos,
      GameBalance.maximumChaos,
    );
    final reputation = (state.reputation + reputationDelta).clamp(
      0,
      GameBalance.maximumReputation,
    );
    if (chaos == state.chaos && reputation == state.reputation) return state;
    return state.copyWith(chaos: chaos, reputation: reputation);
  }
}
