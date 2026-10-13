import '../constants/game_balance.dart';
import '../models/game_state.dart';
import '../models/ghost.dart';
import 'happiness_system.dart';

abstract final class AbilitySystem {
  static GameState advanceActiveTime(GameState state, int seconds) {
    if (seconds <= 0) return state;

    var walletCoins = state.walletCoins;
    var reputation = state.reputation;
    final cooldowns = Map<String, int>.of(state.abilityCooldownSeconds);

    for (final ghost in state.ghosts) {
      if (state.roomForGhost(ghost.id) == null || !_isPeriodic(ghost.kind)) {
        continue;
      }
      final current =
          cooldowns[ghost.id] ?? GameBalance.periodicAbilityIntervalSeconds;
      final triggerCount = seconds < current
          ? 0
          : 1 +
                ((seconds - current) ~/
                    GameBalance.periodicAbilityIntervalSeconds);
      final elapsedAfterFirst = seconds < current ? seconds : seconds - current;
      cooldowns[ghost.id] = triggerCount == 0
          ? current - seconds
          : GameBalance.periodicAbilityIntervalSeconds -
                (elapsedAfterFirst %
                    GameBalance.periodicAbilityIntervalSeconds);

      if (triggerCount == 0 ||
          HappinessSystem.happinessFor(state, ghost.id) <
              GameBalance.periodicAbilityMinimumHappiness) {
        continue;
      }
      switch (ghost.kind) {
        case GhostKind.pocong:
          walletCoins += triggerCount * GameBalance.pocongAbilityCoinReward;
        case GhostKind.kuntilanak:
          reputation =
              (reputation +
                      triggerCount *
                          GameBalance.kuntilanakAbilityReputationReward)
                  .clamp(0, GameBalance.maximumReputation);
        case GhostKind.tuyul:
        case GhostKind.genderuwo:
          break;
      }
    }

    return state.copyWith(
      walletCoins: walletCoins,
      reputation: reputation,
      abilityCooldownSeconds: cooldowns,
    );
  }

  static int repairCostFor(GameState state, String roomId, int baseCost) {
    if (baseCost <= 0) return baseCost;
    final room = state.rooms.where((room) => room.id == roomId).firstOrNull;
    if (room?.occupantId == null) return baseCost;
    final ghost = state.ghostById(room!.occupantId!);
    if (ghost.kind != GhostKind.genderuwo ||
        HappinessSystem.happinessFor(state, ghost.id) <
            GameBalance.conditionalAbilityMinimumHappiness) {
      return baseCost;
    }
    return baseCost * GameBalance.genderuwoRepairCostPercent ~/ 100;
  }

  static bool _isPeriodic(GhostKind kind) =>
      kind == GhostKind.pocong || kind == GhostKind.kuntilanak;
}
