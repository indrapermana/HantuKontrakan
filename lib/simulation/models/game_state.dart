import '../constants/game_balance.dart';
import 'ghost.dart';
import 'room.dart';

class GameState {
  GameState({
    required this.schemaVersion,
    required this.walletCoins,
    required List<GhostState> ghosts,
    required List<RoomState> rooms,
    required this.complaintResolved,
    this.resolutionId,
  }) : ghosts = List.unmodifiable(ghosts),
       rooms = List.unmodifiable(rooms);

  static const int currentSchemaVersion = 1;
  final int schemaVersion;
  final int walletCoins;
  final List<GhostState> ghosts;
  final List<RoomState> rooms;
  final bool complaintResolved;
  final String? resolutionId;

  factory GameState.seeded() => GameState(
    schemaVersion: currentSchemaVersion,
    walletCoins: GameBalance.initialCoins,
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
    List<GhostState>? ghosts,
    List<RoomState>? rooms,
    bool? complaintResolved,
    String? resolutionId,
  }) => GameState(
    schemaVersion: schemaVersion,
    walletCoins: walletCoins ?? this.walletCoins,
    ghosts: ghosts ?? this.ghosts,
    rooms: rooms ?? this.rooms,
    complaintResolved: complaintResolved ?? this.complaintResolved,
    resolutionId: resolutionId ?? this.resolutionId,
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'walletCoins': walletCoins,
    'ghosts': ghosts.map((ghost) => ghost.toJson()).toList(),
    'rooms': rooms.map((room) => room.toJson()).toList(),
    'complaintResolved': complaintResolved,
    'resolutionId': resolutionId,
  };

  factory GameState.fromJson(Map<String, Object?> json) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion != currentSchemaVersion) {
      throw UnsupportedError('Unsupported save schema: $schemaVersion');
    }
    return GameState(
      schemaVersion: schemaVersion! as int,
      walletCoins: json['walletCoins']! as int,
      ghosts: (json['ghosts']! as List<Object?>)
          .map((item) => GhostState.fromJson(item! as Map<String, Object?>))
          .toList(growable: false),
      rooms: (json['rooms']! as List<Object?>)
          .map((item) => RoomState.fromJson(item! as Map<String, Object?>))
          .toList(growable: false),
      complaintResolved: json['complaintResolved']! as bool,
      resolutionId: json['resolutionId'] as String?,
    );
  }
}
