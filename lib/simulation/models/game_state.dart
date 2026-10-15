// ignore_for_file: prefer_initializing_formals

import '../constants/game_balance.dart';
import '../content/progression_definitions.dart';
import 'ghost.dart';
import 'rewarded_rent_claim.dart';
import 'room.dart';
import 'tutorial_step.dart';

class GameState {
  GameState({
    required this.schemaVersion,
    required this.walletCoins,
    this.chaos = GameBalance.initialChaos,
    this.activeSimulationSeconds = 0,
    this.playerLevel = GameBalance.initialPlayerLevel,
    this.playerExperience = 0,
    this.mysticalCrystals = 0,
    this.languageCode,
    this.analyticsConsentGranted = false,
    this.errorReportingConsentGranted = false,
    this.musicMuted = false,
    this.soundMuted = false,
    this.musicVolume = 0.35,
    this.soundVolume = 0.7,
    this.hapticsEnabled = true,
    this.reducedMotionEnabled = false,
    this.reputation = GameBalance.initialReputation,
    int pendingRentMicrocoins = 0,
    Map<String, int>? pendingRentMicrocoinsByRoom,
    this.rentAccrualRemainder = 0,
    Map<String, int>? rentAccrualRemainderByRoom,
    Set<String> completedRentClaimIds = const {},
    this.pendingRewardedRentClaim,
    Set<String> completedRewardedRentClaimIds = const {},
    this.rewardedRentBonusDayKey,
    this.rewardedRentBonusCount = 0,
    Map<String, int> abilityCooldownSeconds = const {},
    this.offlineRateSnapshotMicrocoinsPerMinute,
    this.lastOfflineAccrualTimestampMillis,
    this.unscriptedIncidentsEnabled = true,
    this.activeIncidentId,
    this.lastIncidentResolvedAtActiveSecond,
    List<int> unscriptedIncidentSpawnTimes = const [],
    List<String> recentIncidentIds = const [],
    Set<String> completedIncidentResolutionIds = const {},
    this.incidentRandomState = GameBalance.defaultRandomSeed,
    Set<String> completedRepairIds = const {},
    Set<String> completedMissionIds = const {},
    this.dailyGoalDayKey,
    this.dailyTenantRoomId,
    Map<String, int> dailyGoalProgress = const {},
    Set<String> completedDailyGoalIds = const {},
    this.dailyChestClaimed = false,
    this.activePropertyId = 'kontrakan_pertama',
    Map<String, List<RoomState>>? propertyRoomsById,
    Set<String> ownedFurnitureIds = const {
      'bed',
      'reinforced_shelf',
      'fan',
      'dresser',
      'door',
      'lamp',
      'plant',
      'lantern',
      'curtain',
      'rug',
      'wall_charm',
      'shiny_trinket',
    },
    Set<String> completedGhostStoryIds = const {},
    this.tutorialStep = TutorialStep.completed,
    required List<GhostState> ghosts,
    required List<RoomState> rooms,
    required this.complaintResolved,
    this.resolutionId,
  }) : pendingRentMicrocoins = pendingRentMicrocoins,
       pendingRentMicrocoinsByRoom = Map.unmodifiable(
         _normalizeRoomRent(
           pendingRentMicrocoins,
           pendingRentMicrocoinsByRoom,
           rooms,
         ),
       ),
       rentAccrualRemainderByRoom = Map.unmodifiable(
         _normalizeRoomRent(
           rentAccrualRemainder,
           rentAccrualRemainderByRoom,
           rooms,
         ),
       ),
       completedRentClaimIds = Set.unmodifiable(completedRentClaimIds),
       completedRewardedRentClaimIds = Set.unmodifiable(
         completedRewardedRentClaimIds,
       ),
       abilityCooldownSeconds = Map.unmodifiable(abilityCooldownSeconds),
       unscriptedIncidentSpawnTimes = List.unmodifiable(
         unscriptedIncidentSpawnTimes,
       ),
       recentIncidentIds = List.unmodifiable(recentIncidentIds),
       completedIncidentResolutionIds = Set.unmodifiable(
         completedIncidentResolutionIds,
       ),
       completedRepairIds = Set.unmodifiable(completedRepairIds),
       completedMissionIds = Set.unmodifiable(completedMissionIds),
       dailyGoalProgress = Map.unmodifiable(dailyGoalProgress),
       completedDailyGoalIds = Set.unmodifiable(completedDailyGoalIds),
       propertyRoomsById = Map.unmodifiable({
         ...?propertyRoomsById?.map(
           (id, value) => MapEntry(id, List<RoomState>.unmodifiable(value)),
         ),
         activePropertyId: List<RoomState>.unmodifiable(rooms),
       }),
       ownedFurnitureIds = Set.unmodifiable(ownedFurnitureIds),
       completedGhostStoryIds = Set.unmodifiable(completedGhostStoryIds),
       ghosts = List.unmodifiable(ghosts),
       rooms = List.unmodifiable(rooms) {
    if (pendingRentMicrocoins < 0 ||
        this.pendingRentMicrocoinsByRoom.values.any((value) => value < 0) ||
        this.pendingRentMicrocoinsByRoom.values.fold<int>(0, (a, b) => a + b) !=
            pendingRentMicrocoins ||
        rentAccrualRemainder < 0 ||
        rentAccrualRemainder >= GameBalance.secondsPerMinute ||
        this.rentAccrualRemainderByRoom.values.any(
          (value) => value < 0 || value >= GameBalance.secondsPerMinute,
        ) ||
        playerLevel < 1 ||
        playerLevel > ProgressionDefinitions.levels.length ||
        playerExperience < 0 ||
        mysticalCrystals < 0 ||
        musicVolume < 0 ||
        musicVolume > 1 ||
        soundVolume < 0 ||
        soundVolume > 1 ||
        rewardedRentBonusCount < 0 ||
        rewardedRentBonusCount > GameBalance.maximumRewardedRentBonusesPerDay ||
        (rewardedRentBonusCount > 0 &&
            (rewardedRentBonusDayKey == null ||
                rewardedRentBonusDayKey!.trim().isEmpty)) ||
        (pendingRewardedRentClaim != null &&
            (pendingRewardedRentClaim!.id.trim().isEmpty ||
                pendingRewardedRentClaim!.bonusCoins <= 0 ||
                pendingRewardedRentClaim!.localDayKey.trim().isEmpty ||
                !completedRentClaimIds.contains(pendingRewardedRentClaim!.id) ||
                completedRewardedRentClaimIds.contains(
                  pendingRewardedRentClaim!.id,
                ))) ||
        (languageCode != null &&
            languageCode != 'id' &&
            languageCode != 'en') ||
        reputation < 0 ||
        reputation > GameBalance.maximumReputation ||
        chaos < GameBalance.minimumChaos ||
        chaos > GameBalance.maximumChaos ||
        abilityCooldownSeconds.values.any((seconds) => seconds <= 0) ||
        (offlineRateSnapshotMicrocoinsPerMinute != null &&
            offlineRateSnapshotMicrocoinsPerMinute! < 0) ||
        incidentRandomState < 0 ||
        incidentRandomState > 0xffffffff ||
        !_validDailyGoalState(
          dailyGoalDayKey,
          dailyTenantRoomId,
          dailyGoalProgress,
          completedDailyGoalIds,
          dailyChestClaimed,
        ) ||
        ((dailyGoalDayKey == null) != (dailyTenantRoomId == null)) ||
        (dailyGoalDayKey != null &&
            !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dailyGoalDayKey!)) ||
        (dailyTenantRoomId != null &&
            !this.propertyRoomsById.values
                .expand((rooms) => rooms)
                .any(
                  (room) => room.id == dailyTenantRoomId && room.unlocked,
                )) ||
        unscriptedIncidentSpawnTimes.any(
          (timestamp) => timestamp < 0 || timestamp > activeSimulationSeconds,
        ) ||
        (lastIncidentResolvedAtActiveSecond != null &&
            (lastIncidentResolvedAtActiveSecond! < 0 ||
                lastIncidentResolvedAtActiveSecond! >
                    activeSimulationSeconds))) {
      throw ArgumentError('Game state values are out of range.');
    }
    if (!this.propertyRoomsById.containsKey(activePropertyId)) {
      throw ArgumentError('The active property must exist in the portfolio.');
    }
    _validateOccupancy();
  }

  static const int currentSchemaVersion = 24;
  static const Object _notProvided = Object();
  final int schemaVersion;
  final int walletCoins;
  final int chaos;
  final int activeSimulationSeconds;
  final int playerLevel;
  final int playerExperience;
  final int mysticalCrystals;
  final String? languageCode;
  final bool analyticsConsentGranted;
  final bool errorReportingConsentGranted;
  final bool musicMuted;
  final bool soundMuted;
  final double musicVolume;
  final double soundVolume;
  final bool hapticsEnabled;
  final bool reducedMotionEnabled;
  final int reputation;
  final int pendingRentMicrocoins;
  final Map<String, int> pendingRentMicrocoinsByRoom;
  final int rentAccrualRemainder;
  final Map<String, int> rentAccrualRemainderByRoom;
  final Set<String> completedRentClaimIds;
  final RewardedRentClaim? pendingRewardedRentClaim;
  final Set<String> completedRewardedRentClaimIds;
  final String? rewardedRentBonusDayKey;
  final int rewardedRentBonusCount;
  final Map<String, int> abilityCooldownSeconds;
  final int? offlineRateSnapshotMicrocoinsPerMinute;
  final int? lastOfflineAccrualTimestampMillis;
  final bool unscriptedIncidentsEnabled;
  final String? activeIncidentId;
  final int? lastIncidentResolvedAtActiveSecond;
  final List<int> unscriptedIncidentSpawnTimes;
  final List<String> recentIncidentIds;
  final Set<String> completedIncidentResolutionIds;
  final int incidentRandomState;
  final Set<String> completedRepairIds;
  final Set<String> completedMissionIds;
  final String? dailyGoalDayKey;
  final String? dailyTenantRoomId;
  final Map<String, int> dailyGoalProgress;
  final Set<String> completedDailyGoalIds;
  final bool dailyChestClaimed;
  final String activePropertyId;
  final Map<String, List<RoomState>> propertyRoomsById;
  final Set<String> ownedFurnitureIds;
  final Set<String> completedGhostStoryIds;
  final TutorialStep tutorialStep;
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

  factory GameState.newGame() => GameState(
    schemaVersion: currentSchemaVersion,
    walletCoins: GameBalance.initialCoins,
    unscriptedIncidentsEnabled: false,
    tutorialStep: TutorialStep.openingStory,
    abilityCooldownSeconds: const {
      'pocong_01': GameBalance.periodicAbilityIntervalSeconds,
      'kuntilanak_01': GameBalance.periodicAbilityIntervalSeconds,
    },
    ghosts: const [
      GhostState(id: 'pocong_01', kind: GhostKind.pocong),
      GhostState(id: 'kuntilanak_01', kind: GhostKind.kuntilanak),
      GhostState(id: 'tuyul_01', kind: GhostKind.tuyul),
    ],
    rooms: [
      RoomState(id: 'room_01', column: 0, row: 1),
      RoomState(id: 'room_02', column: 1, row: 1),
      RoomState(id: 'room_03', column: 0, row: 0, unlocked: false),
      RoomState(id: 'room_04', column: 1, row: 0, unlocked: false),
    ],
    complaintResolved: true,
  );

  GhostState ghostById(String id) => ghosts.firstWhere((g) => g.id == id);
  RoomState roomById(String id) => rooms.firstWhere((room) => room.id == id);

  RoomState? roomForGhost(String ghostId) {
    for (final propertyRooms in propertyRoomsById.values) {
      for (final room in propertyRooms) {
        if (room.occupantId == ghostId) return room;
      }
    }
    return null;
  }

  int pendingRentMicrocoinsForRoom(String roomId) =>
      pendingRentMicrocoinsByRoom[roomId] ?? 0;

  int pendingRentCoinsForRoom(String roomId) =>
      pendingRentMicrocoinsForRoom(roomId) ~/ GameBalance.microcoinsPerCoin;

  void _validateOccupancy() {
    final ghostIds = ghosts.map((ghost) => ghost.id).toSet();
    if (ghostIds.length != ghosts.length) {
      throw ArgumentError.value(ghosts, 'ghosts', 'Ghost IDs must be unique.');
    }

    final allRooms = propertyRoomsById.values.expand((rooms) => rooms).toList();
    final roomIds = allRooms.map((room) => room.id).toSet();
    if (roomIds.length != allRooms.length) {
      throw ArgumentError.value(rooms, 'rooms', 'Room IDs must be unique.');
    }

    final occupants = <String>{};
    for (final room in allRooms) {
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
    int? playerExperience,
    int? mysticalCrystals,
    Object? languageCode = _notProvided,
    bool? analyticsConsentGranted,
    bool? errorReportingConsentGranted,
    bool? musicMuted,
    bool? soundMuted,
    double? musicVolume,
    double? soundVolume,
    bool? hapticsEnabled,
    bool? reducedMotionEnabled,
    int? reputation,
    int? pendingRentMicrocoins,
    Map<String, int>? pendingRentMicrocoinsByRoom,
    int? rentAccrualRemainder,
    Map<String, int>? rentAccrualRemainderByRoom,
    Set<String>? completedRentClaimIds,
    Object? pendingRewardedRentClaim = _notProvided,
    Set<String>? completedRewardedRentClaimIds,
    Object? rewardedRentBonusDayKey = _notProvided,
    int? rewardedRentBonusCount,
    Map<String, int>? abilityCooldownSeconds,
    Object? offlineRateSnapshotMicrocoinsPerMinute = _notProvided,
    Object? lastOfflineAccrualTimestampMillis = _notProvided,
    bool? unscriptedIncidentsEnabled,
    Object? activeIncidentId = _notProvided,
    Object? lastIncidentResolvedAtActiveSecond = _notProvided,
    List<int>? unscriptedIncidentSpawnTimes,
    List<String>? recentIncidentIds,
    Set<String>? completedIncidentResolutionIds,
    int? incidentRandomState,
    Set<String>? completedRepairIds,
    Set<String>? completedMissionIds,
    Object? dailyGoalDayKey = _notProvided,
    Object? dailyTenantRoomId = _notProvided,
    Map<String, int>? dailyGoalProgress,
    Set<String>? completedDailyGoalIds,
    bool? dailyChestClaimed,
    String? activePropertyId,
    Map<String, List<RoomState>>? propertyRoomsById,
    Set<String>? ownedFurnitureIds,
    Set<String>? completedGhostStoryIds,
    TutorialStep? tutorialStep,
    List<GhostState>? ghosts,
    List<RoomState>? rooms,
    bool? complaintResolved,
    String? resolutionId,
  }) {
    final nextPropertyId = activePropertyId ?? this.activePropertyId;
    final nextPortfolio = <String, List<RoomState>>{
      ...(propertyRoomsById ?? this.propertyRoomsById),
    };
    if (rooms != null && activePropertyId == null) {
      nextPortfolio[this.activePropertyId] = rooms;
    }
    final nextRooms =
        rooms ??
        (activePropertyId == null
            ? this.rooms
            : nextPortfolio[nextPropertyId] ?? this.rooms);
    return GameState(
      schemaVersion: schemaVersion,
      walletCoins: walletCoins ?? this.walletCoins,
      chaos: chaos ?? this.chaos,
      activeSimulationSeconds:
          activeSimulationSeconds ?? this.activeSimulationSeconds,
      playerLevel: playerLevel ?? this.playerLevel,
      playerExperience: playerExperience ?? this.playerExperience,
      mysticalCrystals: mysticalCrystals ?? this.mysticalCrystals,
      languageCode: identical(languageCode, _notProvided)
          ? this.languageCode
          : languageCode as String?,
      analyticsConsentGranted:
          analyticsConsentGranted ?? this.analyticsConsentGranted,
      errorReportingConsentGranted:
          errorReportingConsentGranted ?? this.errorReportingConsentGranted,
      musicMuted: musicMuted ?? this.musicMuted,
      soundMuted: soundMuted ?? this.soundMuted,
      musicVolume: musicVolume ?? this.musicVolume,
      soundVolume: soundVolume ?? this.soundVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reducedMotionEnabled: reducedMotionEnabled ?? this.reducedMotionEnabled,
      reputation: reputation ?? this.reputation,
      pendingRentMicrocoins:
          pendingRentMicrocoins ??
          (pendingRentMicrocoinsByRoom == null
              ? this.pendingRentMicrocoins
              : pendingRentMicrocoinsByRoom.values.fold<int>(
                  0,
                  (total, value) => total + value,
                )),
      pendingRentMicrocoinsByRoom:
          pendingRentMicrocoinsByRoom ??
          (pendingRentMicrocoins == null
              ? this.pendingRentMicrocoinsByRoom
              : null),
      rentAccrualRemainder: rentAccrualRemainder ?? this.rentAccrualRemainder,
      rentAccrualRemainderByRoom:
          rentAccrualRemainderByRoom ??
          (rentAccrualRemainder == null
              ? this.rentAccrualRemainderByRoom
              : null),
      completedRentClaimIds:
          completedRentClaimIds ?? this.completedRentClaimIds,
      pendingRewardedRentClaim:
          identical(pendingRewardedRentClaim, _notProvided)
          ? this.pendingRewardedRentClaim
          : pendingRewardedRentClaim as RewardedRentClaim?,
      completedRewardedRentClaimIds:
          completedRewardedRentClaimIds ?? this.completedRewardedRentClaimIds,
      rewardedRentBonusDayKey: identical(rewardedRentBonusDayKey, _notProvided)
          ? this.rewardedRentBonusDayKey
          : rewardedRentBonusDayKey as String?,
      rewardedRentBonusCount:
          rewardedRentBonusCount ?? this.rewardedRentBonusCount,
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
      unscriptedIncidentsEnabled:
          unscriptedIncidentsEnabled ?? this.unscriptedIncidentsEnabled,
      activeIncidentId: identical(activeIncidentId, _notProvided)
          ? this.activeIncidentId
          : activeIncidentId as String?,
      lastIncidentResolvedAtActiveSecond:
          identical(lastIncidentResolvedAtActiveSecond, _notProvided)
          ? this.lastIncidentResolvedAtActiveSecond
          : lastIncidentResolvedAtActiveSecond as int?,
      unscriptedIncidentSpawnTimes:
          unscriptedIncidentSpawnTimes ?? this.unscriptedIncidentSpawnTimes,
      recentIncidentIds: recentIncidentIds ?? this.recentIncidentIds,
      completedIncidentResolutionIds:
          completedIncidentResolutionIds ?? this.completedIncidentResolutionIds,
      incidentRandomState: incidentRandomState ?? this.incidentRandomState,
      completedRepairIds: completedRepairIds ?? this.completedRepairIds,
      completedMissionIds: completedMissionIds ?? this.completedMissionIds,
      dailyGoalDayKey: identical(dailyGoalDayKey, _notProvided)
          ? this.dailyGoalDayKey
          : dailyGoalDayKey as String?,
      dailyTenantRoomId: identical(dailyTenantRoomId, _notProvided)
          ? this.dailyTenantRoomId
          : dailyTenantRoomId as String?,
      dailyGoalProgress: dailyGoalProgress ?? this.dailyGoalProgress,
      completedDailyGoalIds:
          completedDailyGoalIds ?? this.completedDailyGoalIds,
      dailyChestClaimed: dailyChestClaimed ?? this.dailyChestClaimed,
      activePropertyId: nextPropertyId,
      propertyRoomsById: nextPortfolio,
      ownedFurnitureIds: ownedFurnitureIds ?? this.ownedFurnitureIds,
      completedGhostStoryIds:
          completedGhostStoryIds ?? this.completedGhostStoryIds,
      tutorialStep: tutorialStep ?? this.tutorialStep,
      ghosts: ghosts ?? this.ghosts,
      rooms: nextRooms,
      complaintResolved: complaintResolved ?? this.complaintResolved,
      resolutionId: resolutionId ?? this.resolutionId,
    );
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'walletCoins': walletCoins,
    'chaos': chaos,
    'activeSimulationSeconds': activeSimulationSeconds,
    'playerLevel': playerLevel,
    'playerExperience': playerExperience,
    'mysticalCrystals': mysticalCrystals,
    'languageCode': languageCode,
    'analyticsConsentGranted': analyticsConsentGranted,
    'errorReportingConsentGranted': errorReportingConsentGranted,
    'musicMuted': musicMuted,
    'soundMuted': soundMuted,
    'musicVolume': musicVolume,
    'soundVolume': soundVolume,
    'hapticsEnabled': hapticsEnabled,
    'reducedMotionEnabled': reducedMotionEnabled,
    'reputation': reputation,
    'pendingRentMicrocoins': pendingRentMicrocoins,
    'pendingRentMicrocoinsByRoom': pendingRentMicrocoinsByRoom,
    'rentAccrualRemainder': rentAccrualRemainder,
    'rentAccrualRemainderByRoom': rentAccrualRemainderByRoom,
    'completedRentClaimIds': completedRentClaimIds.toList(growable: false),
    'pendingRewardedRentClaim': pendingRewardedRentClaim?.toJson(),
    'completedRewardedRentClaimIds': completedRewardedRentClaimIds.toList(
      growable: false,
    ),
    'rewardedRentBonusDayKey': rewardedRentBonusDayKey,
    'rewardedRentBonusCount': rewardedRentBonusCount,
    'abilityCooldownSeconds': abilityCooldownSeconds,
    'offlineRateSnapshotMicrocoinsPerMinute':
        offlineRateSnapshotMicrocoinsPerMinute,
    'lastOfflineAccrualTimestampMillis': lastOfflineAccrualTimestampMillis,
    'unscriptedIncidentsEnabled': unscriptedIncidentsEnabled,
    'activeIncidentId': activeIncidentId,
    'lastIncidentResolvedAtActiveSecond': lastIncidentResolvedAtActiveSecond,
    'unscriptedIncidentSpawnTimes': unscriptedIncidentSpawnTimes,
    'recentIncidentIds': recentIncidentIds,
    'completedIncidentResolutionIds': completedIncidentResolutionIds.toList(
      growable: false,
    ),
    'incidentRandomState': incidentRandomState,
    'completedRepairIds': completedRepairIds.toList(growable: false),
    'completedMissionIds': completedMissionIds.toList(growable: false),
    'dailyGoalDayKey': dailyGoalDayKey,
    'dailyTenantRoomId': dailyTenantRoomId,
    'dailyGoalProgress': dailyGoalProgress,
    'completedDailyGoalIds': completedDailyGoalIds.toList(growable: false),
    'dailyChestClaimed': dailyChestClaimed,
    'activePropertyId': activePropertyId,
    'propertyRoomsById': propertyRoomsById.map(
      (id, rooms) => MapEntry(
        id,
        rooms.map((room) => room.toJson()).toList(growable: false),
      ),
    ),
    'ownedFurnitureIds': ownedFurnitureIds.toList(growable: false),
    'completedGhostStoryIds': completedGhostStoryIds.toList(growable: false),
    'tutorialStep': tutorialStep.name,
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
    final state = switch (schemaVersion) {
      1 => GameState._fromVersion1Json(json),
      2 => GameState._fromVersion2Json(json),
      3 => GameState._fromVersion3Json(json),
      4 => GameState._fromVersion4Json(json),
      5 => GameState._fromVersion5Json(json),
      6 => GameState._fromVersion6Json(json),
      7 => GameState._fromVersion7Json(json),
      8 => GameState._fromVersion8Json(json),
      9 => GameState._fromVersion9Json(json),
      10 => GameState._fromVersion10Json(json),
      11 => GameState._fromVersion11Json(json),
      12 => GameState._fromVersion12Json(json),
      13 => GameState._fromVersion13Json(json),
      14 => GameState._fromVersion14Json(json),
      15 => GameState._fromVersion15Json(json),
      16 => GameState._fromVersion16Json(json),
      17 => GameState._fromVersion17Json(json),
      18 => GameState._fromVersion18Json(json),
      19 => GameState._fromVersion19Json(json),
      20 => GameState._fromVersion20Json(json),
      21 => GameState._fromVersion21Json(json),
      22 => GameState._fromVersion22Json(json),
      23 => GameState._fromVersion23Json(json),
      currentSchemaVersion => GameState._fromVersion24Json(json),
      _ => throw UnsupportedSaveVersion(schemaVersion),
    };
    if (schemaVersion < 14) {
      return state.copyWith(
        playerExperience: ProgressionDefinitions.byLevel(
          state.playerLevel,
        ).requiredExperience,
      );
    }
    return state;
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

  factory GameState._fromVersion11Json(Map<String, Object?> json) => GameState(
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
    unscriptedIncidentsEnabled: json['unscriptedIncidentsEnabled']! as bool,
    activeIncidentId: json['activeIncidentId'] as String?,
    lastIncidentResolvedAtActiveSecond:
        json['lastIncidentResolvedAtActiveSecond'] as int?,
    unscriptedIncidentSpawnTimes:
        (json['unscriptedIncidentSpawnTimes']! as List<Object?>).cast<int>(),
    recentIncidentIds: (json['recentIncidentIds']! as List<Object?>)
        .cast<String>(),
    completedIncidentResolutionIds:
        (json['completedIncidentResolutionIds']! as List<Object?>)
            .cast<String>()
            .toSet(),
    incidentRandomState: json['incidentRandomState']! as int,
    ghosts: _ghostsFromJson(json),
    rooms: _roomsFromJson(json),
    complaintResolved: json['complaintResolved']! as bool,
    resolutionId: json['resolutionId'] as String?,
  );

  factory GameState._fromVersion12Json(Map<String, Object?> json) =>
      GameState._fromVersion11Json(json).copyWith(
        completedRepairIds: (json['completedRepairIds']! as List<Object?>)
            .cast<String>()
            .toSet(),
      );

  factory GameState._fromVersion13Json(Map<String, Object?> json) =>
      GameState._fromVersion12Json(json).copyWith(
        tutorialStep: TutorialStep.values.byName(
          json['tutorialStep']! as String,
        ),
      );

  factory GameState._fromVersion14Json(Map<String, Object?> json) =>
      GameState._fromVersion13Json(
        json,
      ).copyWith(playerExperience: json['playerExperience']! as int);

  factory GameState._fromVersion15Json(Map<String, Object?> json) =>
      GameState._fromVersion14Json(json).copyWith(
        mysticalCrystals: json['mysticalCrystals']! as int,
        completedMissionIds: (json['completedMissionIds']! as List<Object?>)
            .cast<String>()
            .toSet(),
      );

  factory GameState._fromVersion16Json(Map<String, Object?> json) =>
      GameState._fromVersion15Json(
        json,
      ).copyWith(languageCode: json['languageCode'] as String?);

  factory GameState._fromVersion17Json(Map<String, Object?> json) =>
      GameState._fromVersion16Json(json).copyWith(
        analyticsConsentGranted: json['analyticsConsentGranted']! as bool,
      );

  factory GameState._fromVersion18Json(Map<String, Object?> json) =>
      GameState._fromVersion17Json(json).copyWith(
        musicMuted: json['musicMuted']! as bool,
        soundMuted: json['soundMuted']! as bool,
        musicVolume: (json['musicVolume']! as num).toDouble(),
        soundVolume: (json['soundVolume']! as num).toDouble(),
      );

  factory GameState._fromVersion19Json(Map<String, Object?> json) =>
      GameState._fromVersion18Json(json).copyWith(
        pendingRewardedRentClaim: json['pendingRewardedRentClaim'] == null
            ? null
            : RewardedRentClaim.fromJson(
                json['pendingRewardedRentClaim']! as Map<String, Object?>,
              ),
        completedRewardedRentClaimIds:
            (json['completedRewardedRentClaimIds']! as List<Object?>)
                .cast<String>()
                .toSet(),
        rewardedRentBonusDayKey: json['rewardedRentBonusDayKey'] as String?,
        rewardedRentBonusCount: json['rewardedRentBonusCount']! as int,
      );

  factory GameState._fromVersion20Json(Map<String, Object?> json) =>
      GameState._fromVersion19Json(json).copyWith(
        errorReportingConsentGranted:
            json['errorReportingConsentGranted']! as bool,
      );

  factory GameState._fromVersion21Json(Map<String, Object?> json) =>
      GameState._fromVersion20Json(json).copyWith(
        pendingRentMicrocoinsByRoom:
            (json['pendingRentMicrocoinsByRoom']! as Map<String, Object?>).map(
              (roomId, value) => MapEntry(roomId, value! as int),
            ),
        rentAccrualRemainderByRoom:
            (json['rentAccrualRemainderByRoom']! as Map<String, Object?>).map(
              (roomId, value) => MapEntry(roomId, value! as int),
            ),
      );

  factory GameState._fromVersion22Json(Map<String, Object?> json) =>
      GameState._fromVersion21Json(json).copyWith(
        dailyGoalDayKey: json['dailyGoalDayKey'] as String?,
        dailyTenantRoomId: json['dailyTenantRoomId'] as String?,
        dailyGoalProgress: (json['dailyGoalProgress']! as Map<String, Object?>)
            .map((goalId, value) => MapEntry(goalId, value! as int)),
        completedDailyGoalIds: (json['completedDailyGoalIds']! as List<Object?>)
            .cast<String>()
            .toSet(),
        dailyChestClaimed: json['dailyChestClaimed']! as bool,
      );

  factory GameState._fromVersion23Json(Map<String, Object?> json) {
    final activePropertyId = json['activePropertyId']! as String;
    final portfolio = (json['propertyRoomsById']! as Map<String, Object?>).map(
      (id, value) => MapEntry(
        id,
        (value! as List<Object?>)
            .map((item) => RoomState.fromJson(item! as Map<String, Object?>))
            .toList(growable: false),
      ),
    );
    final firstPropertyRooms = portfolio['kontrakan_pertama']!;
    final baseJson = <String, Object?>{
      ...json,
      'rooms': firstPropertyRooms
          .map((room) => room.toJson())
          .toList(growable: false),
    };
    return GameState._fromVersion22Json(baseJson).copyWith(
      activePropertyId: activePropertyId,
      propertyRoomsById: portfolio,
      rooms: portfolio[activePropertyId],
      ownedFurnitureIds: (json['ownedFurnitureIds']! as List<Object?>)
          .cast<String>()
          .toSet(),
      completedGhostStoryIds: (json['completedGhostStoryIds']! as List<Object?>)
          .cast<String>()
          .toSet(),
    );
  }

  factory GameState._fromVersion24Json(Map<String, Object?> json) =>
      GameState._fromVersion23Json(json).copyWith(
        hapticsEnabled: json['hapticsEnabled']! as bool,
        reducedMotionEnabled: json['reducedMotionEnabled']! as bool,
      );

  static Map<String, int> _normalizeRoomRent(
    int total,
    Map<String, int>? byRoom,
    List<RoomState> rooms,
  ) {
    if (byRoom != null) return byRoom;
    if (total == 0) return const {};
    final eligible =
        rooms
            .where((room) => room.unlocked && room.occupantId != null)
            .toList(growable: false)
          ..sort((left, right) => left.id.compareTo(right.id));
    final roomId = eligible.isEmpty ? rooms.first.id : eligible.first.id;
    return {roomId: total};
  }

  static bool _validDailyGoalState(
    String? dayKey,
    String? tenantRoomId,
    Map<String, int> progress,
    Set<String> completed,
    bool chestClaimed,
  ) {
    const targets = <String, int>{
      'daily_collect_rent': 2,
      'daily_active_management': 180,
      'daily_tenant_request': 1,
    };
    if (dayKey == null || tenantRoomId == null) {
      return progress.isEmpty && completed.isEmpty && !chestClaimed;
    }
    if (progress.entries.any(
          (entry) =>
              !targets.containsKey(entry.key) ||
              entry.value < 0 ||
              entry.value > targets[entry.key]!,
        ) ||
        completed.any((goalId) => !targets.containsKey(goalId))) {
      return false;
    }
    return !chestClaimed || completed.containsAll(targets.keys);
  }

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
