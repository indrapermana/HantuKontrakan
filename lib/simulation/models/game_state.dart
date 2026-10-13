import '../constants/game_balance.dart';
import 'ghost.dart';
import 'room.dart';

class GameState {
  GameState({
    required this.schemaVersion,
    required this.walletCoins,
    this.chaos = GameBalance.initialChaos,
    this.activeSimulationSeconds = 0,
    required List<GhostState> ghosts,
    required List<RoomState> rooms,
    required this.complaintResolved,
    this.resolutionId,
  }) : ghosts = List.unmodifiable(ghosts),
       rooms = List.unmodifiable(rooms);

  static const int currentSchemaVersion = 3;
  final int schemaVersion;
  final int walletCoins;
  final int chaos;
  final int activeSimulationSeconds;
  final List<GhostState> ghosts;
  final List<RoomState> rooms;
  final bool complaintResolved;
  final String? resolutionId;

  factory GameState.seeded() => GameState(
    schemaVersion: currentSchemaVersion,
    walletCoins: GameBalance.initialCoins,
    chaos: GameBalance.initialChaos,
    activeSimulationSeconds: 0,
    ghosts: const [
      GhostState(id: 'pocong_01', kind: GhostKind.pocong),
      GhostState(id: 'tuyul_01', kind: GhostKind.tuyul),
    ],
    rooms: const [
      RoomState(id: 'room_01', column: 0, occupantId: 'pocong_01'),
      RoomState(id: 'room_02', column: 1, occupantId: 'tuyul_01'),
    ],
    complaintResolved: false,
  );

  GhostState ghostById(String id) => ghosts.firstWhere((g) => g.id == id);
  RoomState roomById(String id) => rooms.firstWhere((room) => room.id == id);

  RoomState? roomForGhost(String ghostId) {
    for (final room in rooms) {
      if (room.occupantId == ghostId) return room;
    }
    return null;
  }

  GameState copyWith({
    int? walletCoins,
    int? chaos,
    int? activeSimulationSeconds,
    List<GhostState>? ghosts,
    List<RoomState>? rooms,
    bool? complaintResolved,
    String? resolutionId,
  }) => GameState(
    schemaVersion: schemaVersion,
    walletCoins: walletCoins ?? this.walletCoins,
    chaos: chaos ?? this.chaos,
    activeSimulationSeconds:
        activeSimulationSeconds ?? this.activeSimulationSeconds,
    ghosts: ghosts ?? this.ghosts,
    rooms: rooms ?? this.rooms,
    complaintResolved: complaintResolved ?? this.complaintResolved,
    resolutionId: resolutionId ?? this.resolutionId,
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'walletCoins': walletCoins,
    'chaos': chaos,
    'activeSimulationSeconds': activeSimulationSeconds,
    'ghosts': ghosts.map((ghost) => ghost.toJson()).toList(),
    'rooms': rooms.map((room) => room.toJson()).toList(),
    'complaintResolved': complaintResolved,
    'resolutionId': resolutionId,
  };

  factory GameState.fromJson(Map<String, Object?> json) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion is! int) {
      throw const FormatException('Save schemaVersion must be an integer.');
    }
    return switch (schemaVersion) {
      1 => GameState._fromVersion1Json(json),
      2 => GameState._fromVersion2Json(json),
      currentSchemaVersion => GameState._fromVersion3Json(json),
      _ => throw UnsupportedSaveVersion(schemaVersion),
    };
  }

  factory GameState._fromVersion1Json(Map<String, Object?> json) {
    return GameState(
      schemaVersion: currentSchemaVersion,
      walletCoins: json['walletCoins']! as int,
      chaos: GameBalance.initialChaos,
      activeSimulationSeconds: 0,
      ghosts: _ghostsFromJson(json),
      rooms: _roomsFromJson(json),
      complaintResolved: json['complaintResolved']! as bool,
      resolutionId: json['resolutionId'] as String?,
    );
  }

  factory GameState._fromVersion2Json(Map<String, Object?> json) {
    return GameState(
      schemaVersion: currentSchemaVersion,
      walletCoins: json['walletCoins']! as int,
      chaos: json['chaos']! as int,
      activeSimulationSeconds: json['activeSimulationSeconds']! as int,
      ghosts: _ghostsFromJson(json),
      rooms: _roomsFromJson(json),
      complaintResolved: json['complaintResolved']! as bool,
      resolutionId: json['resolutionId'] as String?,
    );
  }

  factory GameState._fromVersion3Json(Map<String, Object?> json) =>
      GameState._fromVersion2Json(json);

  static List<GhostState> _ghostsFromJson(Map<String, Object?> json) =>
      (json['ghosts']! as List<Object?>)
          .map((item) => GhostState.fromJson(item! as Map<String, Object?>))
          .toList(growable: false);

  static List<RoomState> _roomsFromJson(Map<String, Object?> json) =>
      (json['rooms']! as List<Object?>)
          .map((item) => RoomState.fromJson(item! as Map<String, Object?>))
          .toList(growable: false);
}

class UnsupportedSaveVersion implements Exception {
  const UnsupportedSaveVersion(this.version);

  final int version;

  @override
  String toString() => 'Unsupported save schema: $version';
}
