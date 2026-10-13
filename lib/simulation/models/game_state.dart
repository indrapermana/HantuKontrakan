import '../constants/game_balance.dart';
import 'ghost.dart';
import 'room.dart';

class GameState {
  GameState({
    required this.schemaVersion,
    required this.walletCoins,
    this.chaos = GameBalance.initialChaos,
    this.activeSimulationSeconds = 0,
    this.playerLevel = GameBalance.initialPlayerLevel,
    required List<GhostState> ghosts,
    required List<RoomState> rooms,
    required this.complaintResolved,
    this.resolutionId,
  }) : ghosts = List.unmodifiable(ghosts),
       rooms = List.unmodifiable(rooms) {
    _validateOccupancy();
  }

  static const int currentSchemaVersion = 5;
  final int schemaVersion;
  final int walletCoins;
  final int chaos;
  final int activeSimulationSeconds;
  final int playerLevel;
  final List<GhostState> ghosts;
  final List<RoomState> rooms;
  final bool complaintResolved;
  final String? resolutionId;

  factory GameState.seeded() => GameState(
    schemaVersion: currentSchemaVersion,
    walletCoins: GameBalance.initialCoins,
    chaos: GameBalance.initialChaos,
    activeSimulationSeconds: 0,
    playerLevel: GameBalance.initialPlayerLevel,
    ghosts: const [
      GhostState(id: 'pocong_01', kind: GhostKind.pocong),
      GhostState(id: 'tuyul_01', kind: GhostKind.tuyul),
    ],
    rooms: [
      RoomState(id: 'room_01', column: 0, row: 1, occupantId: 'pocong_01'),
      RoomState(id: 'room_02', column: 1, row: 1, occupantId: 'tuyul_01'),
      RoomState(id: 'room_03', column: 0, row: 0, unlocked: false),
      RoomState(id: 'room_04', column: 1, row: 0, unlocked: false),
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

  void _validateOccupancy() {
    final ghostIds = ghosts.map((ghost) => ghost.id).toSet();
    if (ghostIds.length != ghosts.length) {
      throw ArgumentError.value(ghosts, 'ghosts', 'Ghost IDs must be unique.');
    }

    final roomIds = rooms.map((room) => room.id).toSet();
    if (roomIds.length != rooms.length) {
      throw ArgumentError.value(rooms, 'rooms', 'Room IDs must be unique.');
    }

    final occupants = <String>{};
    for (final room in rooms) {
      final occupantId = room.occupantId;
      if (occupantId == null) continue;
      if (!room.unlocked) {
        throw ArgumentError.value(
          room.id,
          'rooms',
          'Locked rooms cannot have occupants.',
        );
      }
      if (!ghostIds.contains(occupantId)) {
        throw ArgumentError.value(
          occupantId,
          'rooms',
          'Every room occupant must reference an existing ghost.',
        );
      }
      if (!occupants.add(occupantId)) {
        throw ArgumentError.value(
          occupantId,
          'rooms',
          'A ghost can occupy only one room.',
        );
      }
    }
  }

  GameState copyWith({
    int? walletCoins,
    int? chaos,
    int? activeSimulationSeconds,
    int? playerLevel,
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
    playerLevel: playerLevel ?? this.playerLevel,
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
    'playerLevel': playerLevel,
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
      3 => GameState._fromVersion3Json(json),
      4 => GameState._fromVersion4Json(json),
      currentSchemaVersion => GameState._fromVersion5Json(json),
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
      rooms: _legacyRoomsFromJson(json),
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
      rooms: _legacyRoomsFromJson(json),
      complaintResolved: json['complaintResolved']! as bool,
      resolutionId: json['resolutionId'] as String?,
    );
  }

  factory GameState._fromVersion3Json(Map<String, Object?> json) =>
      GameState._fromVersion2Json(json);

  factory GameState._fromVersion4Json(Map<String, Object?> json) =>
      GameState._fromVersion2Json(json);

  factory GameState._fromVersion5Json(Map<String, Object?> json) => GameState(
    schemaVersion: currentSchemaVersion,
    walletCoins: json['walletCoins']! as int,
    chaos: json['chaos']! as int,
    activeSimulationSeconds: json['activeSimulationSeconds']! as int,
    playerLevel: json['playerLevel']! as int,
    ghosts: _ghostsFromJson(json),
    rooms: _roomsFromJson(json),
    complaintResolved: json['complaintResolved']! as bool,
    resolutionId: json['resolutionId'] as String?,
  );

  static List<GhostState> _ghostsFromJson(Map<String, Object?> json) =>
      (json['ghosts']! as List<Object?>)
          .map((item) => GhostState.fromJson(item! as Map<String, Object?>))
          .toList(growable: false);

  static List<RoomState> _roomsFromJson(Map<String, Object?> json) =>
      (json['rooms']! as List<Object?>)
          .map((item) => RoomState.fromJson(item! as Map<String, Object?>))
          .toList(growable: false);

  static List<RoomState> _legacyRoomsFromJson(Map<String, Object?> json) {
    final rooms = _roomsFromJson(json).toList();
    if (!rooms.any((room) => room.id == 'room_03')) {
      rooms.add(RoomState(id: 'room_03', column: 0, row: 0, unlocked: false));
    }
    if (!rooms.any((room) => room.id == 'room_04')) {
      rooms.add(RoomState(id: 'room_04', column: 1, row: 0, unlocked: false));
    }
    return rooms;
  }
}

class UnsupportedSaveVersion implements Exception {
  const UnsupportedSaveVersion(this.version);

  final int version;

  @override
  String toString() => 'Unsupported save schema: $version';
}
