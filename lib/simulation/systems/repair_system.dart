import '../constants/game_balance.dart';
import '../models/game_state.dart';
import '../models/room.dart';
import 'ability_system.dart';

abstract final class RepairSystem {
  static int costFor(GameState state, String roomId) {
    final room = state.rooms.where((room) => room.id == roomId).firstOrNull;
    if (room == null || !room.unlocked || !room.repairRequired) return 0;
    final durabilityLevel = room.levelFor(RoomAttribute.durability);
    final durabilityPercent =
        GameBalance.roomRepairCostPercentByDurability[durabilityLevel]!;
    final durabilityAdjusted =
        GameBalance.roomRepairBaseCost * durabilityPercent ~/ 100;
    return AbilitySystem.repairCostFor(state, roomId, durabilityAdjusted);
  }

  static GameState repair(GameState state, String roomId, String repairId) {
    if (repairId.trim().isEmpty ||
        state.completedRepairIds.contains(repairId)) {
      return state;
    }
    final room = state.rooms.where((room) => room.id == roomId).firstOrNull;
    if (room == null || !room.unlocked || !room.repairRequired) return state;
    final cost = costFor(state, roomId);
    if (cost <= 0 || state.walletCoins < cost) return state;

    return state.copyWith(
      walletCoins: state.walletCoins - cost,
      completedRepairIds: {...state.completedRepairIds, repairId},
      rooms: state.rooms
          .map(
            (candidate) => candidate.id == roomId
                ? candidate.copyWith(
                    occupantId: candidate.occupantId,
                    repairRequired: false,
                  )
                : candidate,
          )
          .toList(growable: false),
    );
  }
}
