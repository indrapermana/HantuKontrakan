import '../constants/game_balance.dart';
import '../content/ghost_definitions.dart';
import '../models/game_state.dart';
import '../models/ghost.dart';
import '../models/room.dart';
import 'happiness_system.dart';

abstract final class RentSystem {
  static int rentPerMinuteMicrocoinsFor(GameState state, String ghostId) {
    final ghost = state.ghostById(ghostId);
    final room = state.roomForGhost(ghostId);
    if (room == null || !room.unlocked) return 0;
    final definition = GhostDefinitions.byKind(ghost.kind);
    final happiness = HappinessSystem.happinessFor(state, ghostId);
    final multipliedRate =
        definition.baseRentPerMinute *
        _happinessPercent(happiness) *
        _roomPercent(room) *
        _chaosPercent(state.chaos);
    final abilityBonus = ghost.kind == GhostKind.tuyul && happiness >= 60
        ? definition.baseRentPerMinute *
              GameBalance.tuyulBaseRentBonusPercent *
              (GameBalance.microcoinsPerCoin ~/ 100)
        : 0;
    return multipliedRate + abilityBonus;
  }

  static int totalRentPerMinuteMicrocoins(GameState state) => state.rooms
      .where((room) => room.unlocked && room.occupantId != null)
      .fold(
        0,
        (total, room) =>
            total + rentPerMinuteMicrocoinsFor(state, room.occupantId!),
      );

  static GameState accrue(GameState state, int elapsedSeconds) {
    if (elapsedSeconds <= 0) return state;
    final numerator =
        state.rentAccrualRemainder +
        totalRentPerMinuteMicrocoins(state) * elapsedSeconds;
    return state.copyWith(
      activeSimulationSeconds: state.activeSimulationSeconds + elapsedSeconds,
      pendingRentMicrocoins:
          state.pendingRentMicrocoins +
          numerator ~/ GameBalance.secondsPerMinute,
      rentAccrualRemainder: numerator % GameBalance.secondsPerMinute,
    );
  }

  static int _happinessPercent(int happiness) {
    if (happiness >= 80) return 150;
    if (happiness >= 60) return 100;
    if (happiness >= 40) return 75;
    return 40;
  }

  static int _roomPercent(RoomState room) =>
      100 + (5 * room.levelFor(RoomAttribute.comfort));

  static int _chaosPercent(int chaos) {
    if (chaos >= 70) return 125;
    if (chaos >= 30) return 115;
    return 100;
  }
}
