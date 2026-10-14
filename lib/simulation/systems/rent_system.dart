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
    final pending = Map<String, int>.of(state.pendingRentMicrocoinsByRoom);
    final remainders = Map<String, int>.of(state.rentAccrualRemainderByRoom);
    final eligibleRooms =
        state.rooms
            .where((room) => room.unlocked && room.occupantId != null)
            .toList(growable: false)
          ..sort((left, right) => left.id.compareTo(right.id));
    for (final room in eligibleRooms) {
      final numerator =
          (remainders[room.id] ?? 0) +
          rentPerMinuteMicrocoinsFor(state, room.occupantId!) * elapsedSeconds;
      pending[room.id] =
          (pending[room.id] ?? 0) + numerator ~/ GameBalance.secondsPerMinute;
      remainders[room.id] = numerator % GameBalance.secondsPerMinute;
    }
    return state.copyWith(
      activeSimulationSeconds: state.activeSimulationSeconds + elapsedSeconds,
      pendingRentMicrocoinsByRoom: pending,
      rentAccrualRemainder:
          remainders.values.fold<int>(0, (sum, value) => sum + value) %
          GameBalance.secondsPerMinute,
      rentAccrualRemainderByRoom: remainders,
    );
  }

  static Map<String, int> distributeMicrocoinsByRoom(
    GameState state,
    int addedMicrocoins,
  ) {
    final result = Map<String, int>.of(state.pendingRentMicrocoinsByRoom);
    if (addedMicrocoins <= 0) return result;
    final rates = <String, int>{
      for (final room in state.rooms)
        if (room.unlocked && room.occupantId != null)
          room.id: rentPerMinuteMicrocoinsFor(state, room.occupantId!),
    };
    final roomIds = rates.keys.toList()..sort();
    final totalRate = rates.values.fold<int>(0, (total, rate) => total + rate);
    if (roomIds.isEmpty || totalRate <= 0) {
      final fallback = state.rooms.map((room) => room.id).toList()..sort();
      if (fallback.isNotEmpty) {
        result[fallback.first] =
            (result[fallback.first] ?? 0) + addedMicrocoins;
      }
      return result;
    }
    var allocated = 0;
    for (var index = 0; index < roomIds.length; index += 1) {
      final roomId = roomIds[index];
      final share = index == roomIds.length - 1
          ? addedMicrocoins - allocated
          : addedMicrocoins * rates[roomId]! ~/ totalRate;
      result[roomId] = (result[roomId] ?? 0) + share;
      allocated += share;
    }
    return result;
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
