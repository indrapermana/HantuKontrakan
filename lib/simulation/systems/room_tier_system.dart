import '../models/room.dart';

abstract final class RoomTierSystem {
  static int tierFor(RoomState room) {
    final upgradeLevels = room.upgrades.values.fold<int>(0, (a, b) => a + b);
    final score = upgradeLevels + room.furnitureIds.length;
    if (score >= 7) return 3;
    if (score >= 3) return 2;
    return 1;
  }

  static int progressForNextTier(RoomState room) {
    final score =
        room.upgrades.values.fold<int>(0, (a, b) => a + b) +
        room.furnitureIds.length;
    return switch (tierFor(room)) {
      1 => score,
      2 => score - 3,
      _ => 0,
    };
  }

  static int requiredForNextTier(RoomState room) => switch (tierFor(room)) {
    1 => 3,
    2 => 4,
    _ => 0,
  };
}
