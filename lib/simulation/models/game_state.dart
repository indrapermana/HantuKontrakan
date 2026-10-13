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
    this.reputation = GameBalance.initialReputation,
    this.pendingRentMicrocoins = 0,
    this.rentAccrualRemainder = 0,
    Set<String> completedRentClaimIds = const {},
    Map<String, int> abilityCooldownSeconds = const {},
    this.offlineRateSnapshotMicrocoinsPerMinute,
    this.lastOfflineAccrualTimestampMillis,
    required List<GhostState> ghosts,
    required List<RoomState> rooms,
    required this.complaintResolved,
    this.resolutionId,
  }) : completedRentClaimIds = Set.unmodifiable(completedRentClaimIds),
       abilityCooldownSeconds = Map.unmodifiable(abilityCooldownSeconds),
       ghosts = List.unmodifiable(ghosts),
       rooms = List.unmodifiable(rooms) {
    if (pendingRentMicrocoins < 0 ||
        rentAccrualRemainder < 0 ||
        rentAccrualRemainder >= GameBalance.secondsPerMinute ||
        reputation < 0 ||
        reputation > GameBalance.maximumReputation ||
        chaos < GameBalance.minimumChaos ||
        chaos > GameBalance.maximumChaos ||
        abilityCooldownSeconds.values.any((seconds) => seconds <= 0) ||
        (offlineRateSnapshotMicrocoinsPerMinute != null &&
            offlineRateSnapshotMicrocoinsPerMinute! < 0)) {
      throw ArgumentError('Rent accumulation values are out of range.');
    }
    _validateOccupancy();
  }

  static const int currentSchemaVersion = 10;
  static const Object _notProvided = Object();
  final int schemaVersion;
  final int walletCoins;
  final int chaos;
  final int activeSimulationSeconds;
  final int playerLevel;
  final int reputation;
  final int pendingRentMicrocoins;
  final int rentAccrualRemainder;
  final Set<String> completedRentClaimIds;
  final Map<String, int> abilityCooldownSeconds;
  final int? offlineRateSnapshotMicrocoinsPerMinute;
  final int? lastOfflineAccrualTimestampMillis;
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
    reputation: GameBalance.initialReputation,
    pendingRentMicrocoins: 0,
    rentAccrualRemainder: 0,
    completedRentClaimIds: const {},
    abilityCooldownSeconds: const {
      'pocong_01': GameBalance.periodicAbilityIntervalSeconds,
    },
    offlineRateSnapshotMicrocoinsPerMinute: null,
    lastOfflineAccrualTimestampMillis: null,
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
    int? reputation,
    int? pendingRentMicrocoins,
    int? rentAccrualRemainder,
    Set<String>? completedRentClaimIds,
    Map<String, int>? abilityCooldownSeconds,
    Object? offlineRateSnapshotMicrocoinsPerMinute = _notProvided,
    Object? lastOfflineAccrualTimestampMillis = _notProvided,
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
    reputation: reputation ?? this.reputation,
    pendingRentMicrocoins: pendingRentMicrocoins ?? this.pendingRentMicrocoins,
    rentAccrualRemainder: rentAccrualRemainder ?? this.rentAccrualRemainder,
    completedRentClaimIds: completedRentClaimIds ?? this.completedRentClaimIds,
    abilityCooldownSeconds:
        abilityCooldownSeconds ?? this.abilityCooldownSeconds,
    offlineRateSnapshotMicrocoinsPerMinute:
        identical(offlineRateSnapshotMicrocoinsPerMinute, _notProvided)
        ? this.offlineRateSnapshotMicrocoinsPerMinute
        : offlineRateSnapshotMicrocoinsPerMinute as int?,
    lastOfflineAccrualTimestampMillis:
        identical(lastOfflineAccrualTimestampMillis, _notProvided)
        ? this.lastOfflineAccrualTimestampMillis
        : lastOfflineAccrualTimestampMillis as int?,
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
    'reputation': reputation,
    'pendingRentMicrocoins': pendingRentMicrocoins,
    'rentAccrualRemainder': rentAccrualRemainder,
    'completedRentClaimIds': completedRentClaimIds.toList(growable: false),
    'abilityCooldownSeconds': abilityCooldownSeconds,
    'offlineRateSnapshotMicrocoinsPerMinute':
        offlineRateSnapshotMicrocoinsPerMinute,
    'lastOfflineAccrualTimestampMillis': lastOfflineAccrualTimestampMillis,
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
      5 => GameState._fromVersion5Json(json),
      6 => GameState._fromVersion6Json(json),
      7 => GameState._fromVersion7Json(json),
      8 => GameState._fromVersion8Json(json),
      9 => GameState._fromVersion9Json(json),
      currentSchemaVersion => GameState._fromVersion10Json(json),
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

  factory GameState._fromVersion6Json(Map<String, Object?> json) => GameState(
    schemaVersion: currentSchemaVersion,
    walletCoins: json['walletCoins']! as int,
    chaos: json['chaos']! as int,
    activeSimulationSeconds: json['activeSimulationSeconds']! as int,
    playerLevel: json['playerLevel']! as int,
    pendingRentMicrocoins: json['pendingRentMicrocoins']! as int,
    rentAccrualRemainder: json['rentAccrualRemainder']! as int,
    ghosts: _ghostsFromJson(json),
    rooms: _roomsFromJson(json),
    complaintResolved: json['complaintResolved']! as bool,
    resolutionId: json['resolutionId'] as String?,
  );

  factory GameState._fromVersion7Json(Map<String, Object?> json) => GameState(
    schemaVersion: currentSchemaVersion,
    walletCoins: json['walletCoins']! as int,
    chaos: json['chaos']! as int,
    activeSimulationSeconds: json['activeSimulationSeconds']! as int,
    playerLevel: json['playerLevel']! as int,
    pendingRentMicrocoins: json['pendingRentMicrocoins']! as int,
    rentAccrualRemainder: json['rentAccrualRemainder']! as int,
    completedRentClaimIds: (json['completedRentClaimIds']! as List<Object?>)
        .cast<String>()
        .toSet(),
    ghosts: _ghostsFromJson(json),
    rooms: _roomsFromJson(json),
    complaintResolved: json['complaintResolved']! as bool,
    resolutionId: json['resolutionId'] as String?,
  );

  factory GameState._fromVersion8Json(Map<String, Object?> json) => GameState(
    schemaVersion: currentSchemaVersion,
    walletCoins: json['walletCoins']! as int,
    chaos: json['chaos']! as int,
    activeSimulationSeconds: json['activeSimulationSeconds']! as int,
    playerLevel: json['playerLevel']! as int,
    pendingRentMicrocoins: json['pendingRentMicrocoins']! as int,
    rentAccrualRemainder: json['rentAccrualRemainder']! as int,
    completedRentClaimIds: (json['completedRentClaimIds']! as List<Object?>)
        .cast<String>()
        .toSet(),
    offlineRateSnapshotMicrocoinsPerMinute:
        json['offlineRateSnapshotMicrocoinsPerMinute'] as int?,
    lastOfflineAccrualTimestampMillis:
        json['lastOfflineAccrualTimestampMillis'] as int?,
    ghosts: _ghostsFromJson(json),
    rooms: _roomsFromJson(json),
    complaintResolved: json['complaintResolved']! as bool,
    resolutionId: json['resolutionId'] as String?,
  );

  factory GameState._fromVersion9Json(Map<String, Object?> json) => GameState(
    schemaVersion: currentSchemaVersion,
    walletCoins: json['walletCoins']! as int,
    chaos: json['chaos']! as int,
    activeSimulationSeconds: json['activeSimulationSeconds']! as int,
    playerLevel: json['playerLevel']! as int,
    reputation: json['reputation']! as int,
    pendingRentMicrocoins: json['pendingRentMicrocoins']! as int,
    rentAccrualRemainder: json['rentAccrualRemainder']! as int,
    completedRentClaimIds: (json['completedRentClaimIds']! as List<Object?>)
        .cast<String>()
        .toSet(),
    abilityCooldownSeconds:
        (json['abilityCooldownSeconds']! as Map<String, Object?>).map(
          (ghostId, seconds) => MapEntry(ghostId, seconds! as int),
        ),
    offlineRateSnapshotMicrocoinsPerMinute:
        json['offlineRateSnapshotMicrocoinsPerMinute'] as int?,
    lastOfflineAccrualTimestampMillis:
        json['lastOfflineAccrualTimestampMillis'] as int?,
    ghosts: _ghostsFromJson(json),
    rooms: _roomsFromJson(json),
    complaintResolved: json['complaintResolved']! as bool,
    resolutionId: json['resolutionId'] as String?,
  );

  factory GameState._fromVersion10Json(Map<String, Object?> json) =>
      GameState._fromVersion9Json(json);

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
