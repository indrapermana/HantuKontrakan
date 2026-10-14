import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/application/game_controller.dart';
import 'package:hantu_kontrakan/application/simulation_runtime.dart';
import 'package:hantu_kontrakan/services/analytics_service.dart';
import 'package:hantu_kontrakan/services/audio_service.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';

void main() {
  test(
    'resolved complaint and swapped rooms survive controller reload',
    () async {
      final saves = MemorySaveService(
        initialResult: SaveLoaded(GameState.seeded()),
      );
      final first = GameController(saveService: saves);
      await first.initialize();
      await first.moveGhost('pocong_01', 'room_02', allowSwap: true);
      await first.resolveComplaint(ComplaintChoice.peaceOffering);

      final reloaded = GameController(saveService: saves);
      await reloaded.initialize();

      expect(reloaded.state.walletCoins, 175);
      expect(reloaded.state.complaintResolved, isTrue);
      expect(reloaded.state.roomById('room_01').occupantId, 'tuyul_01');
      expect(reloaded.happinessFor('pocong_01'), 40);
    },
  );

  test(
    'analytics requires consent and revocation stops future events',
    () async {
      final analytics = _RecordingAnalyticsService();
      final saves = MemorySaveService(
        initialResult: SaveLoaded(
          GameState.seeded().copyWith(pendingRentMicrocoins: 2000000),
        ),
      );
      final controller = GameController(
        saveService: saves,
        analyticsService: analytics,
      );

      await controller.initialize();
      await controller.collectAllRent(claimId: 'before-consent');
      expect(analytics.events, isEmpty);

      expect(await controller.setAnalyticsConsent(true), isTrue);
      expect(saves.storedState?.analyticsConsentGranted, isTrue);
      await controller.upgradeRoom('room_01', RoomAttribute.comfort);
      expect(
        analytics.events.single.name,
        GameplayAnalyticsEventName.roomUpgraded,
      );
      expect(analytics.events.single.parameters, {
        'room_id': 'room_01',
        'attribute': 'comfort',
        'level': 1,
      });

      expect(await controller.setAnalyticsConsent(false), isTrue);
      await controller.upgradeRoom('room_01', RoomAttribute.silence);
      expect(analytics.events, hasLength(1));
      expect(saves.storedState?.analyticsConsentGranted, isFalse);
    },
  );

  test('tutorial gameplay emits only approved content identifiers', () async {
    final analytics = _RecordingAnalyticsService();
    final saves = MemorySaveService(
      initialResult: SaveLoaded(
        GameState.newGame().copyWith(analyticsConsentGranted: true),
      ),
    );
    final controller = GameController(
      saveService: saves,
      analyticsService: analytics,
    );

    await controller.initialize();
    await controller.continueTutorial();
    await controller.placeGhost('pocong_01', 'room_01');
    await controller.collectAllRent(claimId: 'tutorial-rent');
    await controller.placeGhost('kuntilanak_01', 'room_02');
    await controller.resolveIncident(
      'pak_rt_complaint',
      'join_patrol',
      resolutionId: 'analytics-resolution',
    );
    await controller.continueTutorial();

    expect(analytics.events.map((event) => event.name), [
      GameplayAnalyticsEventName.appOpen,
      GameplayAnalyticsEventName.tutorialStarted,
      GameplayAnalyticsEventName.ghostPlaced,
      GameplayAnalyticsEventName.rentCollected,
      GameplayAnalyticsEventName.incidentStarted,
      GameplayAnalyticsEventName.ghostPlaced,
      GameplayAnalyticsEventName.incidentChoiceSelected,
      GameplayAnalyticsEventName.incidentResolved,
      GameplayAnalyticsEventName.tutorialCompleted,
    ]);
    expect(
      analytics.events.expand((event) => event.parameters.keys),
      isNot(contains(anyOf('email', 'name', 'device_id', 'user_id'))),
    );
  });

  test(
    'analytics adapter failures never roll back gameplay or saves',
    () async {
      final saves = MemorySaveService(
        initialResult: SaveLoaded(
          GameState.seeded().copyWith(
            analyticsConsentGranted: true,
            pendingRentMicrocoins: 2000000,
          ),
        ),
      );
      final controller = GameController(
        saveService: saves,
        analyticsService: _FailingAnalyticsService(),
      );

      await controller.initialize();
      await controller.collectAllRent(claimId: 'safe-claim');

      expect(controller.state.walletCoins, 202);
      expect(saves.storedState?.walletCoins, 202);
      expect(saves.storedState?.completedRentClaimIds, {'safe-claim'});
    },
  );

  test(
    'audio settings, effects, lifecycle, and reload use the adapter',
    () async {
      final audio = _RecordingAudioService();
      final saves = MemorySaveService(
        initialResult: SaveLoaded(
          GameState.seeded().copyWith(pendingRentMicrocoins: 2000000),
        ),
      );
      final controller = GameController(
        saveService: saves,
        audioService: audio,
      );

      await controller.initialize();
      expect(audio.initialized, hasLength(1));
      expect(audio.initialized.single.musicVolume, 0.35);

      expect(
        await controller.setAudioPreferences(
          musicMuted: true,
          soundMuted: false,
          musicVolume: 0.2,
          soundVolume: 0.6,
        ),
        isTrue,
      );
      expect(audio.updated.single.musicMuted, isTrue);
      expect(saves.storedState?.musicVolume, 0.2);

      await controller.collectAllRent(claimId: 'audio-rent');
      expect(audio.cues, [AudioCue.coin]);
      await controller.pauseForOffline();
      await controller.resumeFromOffline();
      expect(audio.pauseCount, 1);
      expect(audio.resumeCount, 1);

      await controller.setAudioPreferences(
        musicMuted: true,
        soundMuted: true,
        musicVolume: 0.2,
        soundVolume: 0.6,
      );
      await controller.upgradeRoom('room_01', RoomAttribute.comfort);
      expect(audio.cues, [AudioCue.coin]);

      final reloadedAudio = _RecordingAudioService();
      final reloaded = GameController(
        saveService: saves,
        audioService: reloadedAudio,
      );
      await reloaded.initialize();
      expect(reloadedAudio.initialized.single.musicMuted, isTrue);
      expect(reloadedAudio.initialized.single.soundMuted, isTrue);
      expect(reloadedAudio.initialized.single.soundVolume, 0.6);
    },
  );

  test('rejected save seeds safely and exposes recovery reason', () async {
    final saves = MemorySaveService(
      initialResult: const SaveRejected(
        reason: SaveRejectionReason.unsupportedVersion,
        schemaVersion: 99,
      ),
    );
    final controller = GameController(saveService: saves);

    await controller.initialize();

    expect(controller.state.walletCoins, 200);
    expect(
      controller.saveRecoveryReason,
      SaveRejectionReason.unsupportedVersion,
    );
    expect(saves.storedResult, isA<SaveRejected>());
  });

  test('debug clock, seed, tick and reset are deterministic', () async {
    final clock = _FixedClock(DateTime.utc(2026, 10, 13, 12));
    final saves = MemorySaveService(
      initialResult: SaveLoaded(GameState.seeded()),
    );
    final controller = GameController(
      saveService: saves,
      clock: clock,
      randomSeed: 42,
    );
    await controller.initialize();

    expect(controller.debugNow, DateTime.utc(2026, 10, 13, 12));
    expect(controller.randomSeed, 42);
    expect(controller.state.chaos, 40);
    expect(controller.state.activeSimulationSeconds, 0);

    await controller.debugTick();
    expect(controller.state.activeSimulationSeconds, 1);
    expect(saves.storedState?.activeSimulationSeconds, 1);

    await controller.resolveComplaint(ComplaintChoice.installSoundproofing);
    expect(controller.state.walletCoins, 150);
    await controller.resetState();

    expect(controller.state.walletCoins, 200);
    expect(controller.state.chaos, 40);
    expect(controller.state.activeSimulationSeconds, 0);
    expect(controller.state.complaintResolved, isFalse);
    expect(saves.storedState?.walletCoins, 200);
  });

  test('rent claim remains idempotent after controller reload', () async {
    final initial = GameState.seeded().copyWith(pendingRentMicrocoins: 2250000);
    final saves = MemorySaveService(initialResult: SaveLoaded(initial));
    final first = GameController(saveService: saves);
    await first.initialize();
    await first.collectAllRent(claimId: 'stable-claim');

    final reloaded = GameController(saveService: saves);
    await reloaded.initialize();
    await reloaded.collectAllRent(claimId: 'stable-claim');

    expect(reloaded.state.walletCoins, 202);
    expect(reloaded.state.pendingRentMicrocoins, 250000);
    expect(reloaded.state.completedRentClaimIds, {'stable-claim'});
  });

  test('experience level and unlock gates survive controller reload', () async {
    final saves = MemorySaveService();
    final first = GameController(saveService: saves);
    await first.initialize();
    await first.grantExperience(250);

    final reloaded = GameController(saveService: saves);
    await reloaded.initialize();

    expect(reloaded.state.playerExperience, 250);
    expect(reloaded.state.playerLevel, 3);
    await reloaded.placeGhost('tuyul_01', 'room_02');
    expect(reloaded.state.roomById('room_02').occupantId, 'tuyul_01');
  });

  test(
    'mission reward persists and duplicate controller claim is ignored',
    () async {
      var initial = GameRules.continueTutorial(GameState.newGame());
      initial = GameRules.placeGhost(initial, 'pocong_01', 'room_01');
      final saves = MemorySaveService(initialResult: SaveLoaded(initial));
      final first = GameController(saveService: saves);
      await first.initialize();

      expect(await first.claimMissionReward('place_pocong'), isTrue);
      expect(await first.claimMissionReward('place_pocong'), isFalse);

      final reloaded = GameController(saveService: saves);
      await reloaded.initialize();
      expect(reloaded.state.walletCoins, 225);
      expect(reloaded.state.playerExperience, 25);
      expect(reloaded.state.completedMissionIds, {'place_pocong'});
    },
  );

  test('initialize credits persisted offline snapshot exactly once', () async {
    final pausedAt = DateTime.utc(2026, 10, 13, 8);
    final resumedAt = pausedAt.add(const Duration(hours: 2));
    final initial = GameState.seeded().copyWith(
      offlineRateSnapshotMicrocoinsPerMinute: 40000000,
      lastOfflineAccrualTimestampMillis: pausedAt.millisecondsSinceEpoch,
    );
    final saves = MemorySaveService(initialResult: SaveLoaded(initial));
    final clock = _MutableClock(resumedAt);

    final first = GameController(saveService: saves, clock: clock);
    await first.initialize();
    final credited = first.state.pendingRentMicrocoins;

    final reloaded = GameController(saveService: saves, clock: clock);
    await reloaded.initialize();

    expect(credited, 2400000000);
    expect(reloaded.state.pendingRentMicrocoins, credited);
    expect(reloaded.state.offlineRateSnapshotMicrocoinsPerMinute, isNull);
  });

  test('pause persists one rate snapshot for lifecycle resume', () async {
    final clock = _MutableClock(DateTime.utc(2026, 10, 13, 8));
    final saves = MemorySaveService(
      initialResult: SaveLoaded(GameState.seeded()),
    );
    final controller = GameController(saveService: saves, clock: clock);
    await controller.initialize();

    await controller.pauseForOffline();
    final firstTimestamp = saves.storedState?.lastOfflineAccrualTimestampMillis;
    clock.value = clock.value.add(const Duration(minutes: 10));
    await controller.pauseForOffline();

    expect(
      saves.storedState?.offlineRateSnapshotMicrocoinsPerMinute,
      greaterThan(0),
    );
    expect(
      saves.storedState?.lastOfflineAccrualTimestampMillis,
      firstTimestamp,
    );
  });

  test('overlapping lifecycle saves remain ordered', () async {
    final clock = _MutableClock(DateTime.utc(2026, 10, 13, 8));
    final saves = _ReorderingSaveService();
    final controller = GameController(saveService: saves, clock: clock);
    await controller.initialize();

    final pause = controller.pauseForOffline();
    clock.value = clock.value.add(const Duration(hours: 2));
    final resume = controller.resumeFromOffline();
    await Future.wait([pause, resume]);

    expect(saves.storedState?.offlineRateSnapshotMicrocoinsPerMinute, isNull);
    expect(saves.storedState?.pendingRentMicrocoins, greaterThan(0));
  });

  test('ability cooldown continues after controller reload', () async {
    final initial = GameState(
      schemaVersion: GameState.currentSchemaVersion,
      walletCoins: 0,
      chaos: 0,
      ghosts: const [
        GhostState(
          id: 'pocong_01',
          kind: GhostKind.pocong,
          eventHappinessModifier: 20,
        ),
      ],
      rooms: [
        RoomState(
          id: 'room_01',
          column: 0,
          occupantId: 'pocong_01',
          roomTagLevels: const {'quiet': 1},
        ),
      ],
      complaintResolved: false,
    );
    final saves = MemorySaveService(initialResult: SaveLoaded(initial));
    final first = GameController(saveService: saves);
    await first.initialize();
    await first.advanceSimulation(300);

    final reloaded = GameController(saveService: saves);
    await reloaded.initialize();
    await reloaded.advanceSimulation(300);

    expect(reloaded.state.walletCoins, 30);
    expect(reloaded.state.abilityCooldownSeconds['pocong_01'], 600);
  });

  test(
    'repair persists and duplicate controller request cannot charge twice',
    () async {
      final seed = GameState.seeded();
      final damaged = seed.copyWith(
        rooms: seed.rooms
            .map(
              (room) => room.id == 'room_01'
                  ? room.copyWith(
                      occupantId: room.occupantId,
                      repairRequired: true,
                      upgrades: const {RoomAttribute.durability: 1},
                    )
                  : room,
            )
            .toList(growable: false),
      );
      final saves = MemorySaveService(initialResult: SaveLoaded(damaged));
      final first = GameController(saveService: saves);
      await first.initialize();

      expect(first.repairCostFor('room_01'), 80);
      expect(
        await first.repairRoom('room_01', repairId: 'stable-repair'),
        isTrue,
      );
      expect(
        await first.repairRoom('room_01', repairId: 'stable-repair'),
        isFalse,
      );

      final reloaded = GameController(saveService: saves);
      await reloaded.initialize();
      expect(reloaded.state.walletCoins, 120);
      expect(reloaded.state.roomById('room_01').repairRequired, isFalse);
      expect(reloaded.state.completedRepairIds, {'stable-repair'});
    },
  );
}

class _FixedClock implements GameClock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

class _MutableClock implements GameClock {
  _MutableClock(this.value);

  DateTime value;

  @override
  DateTime now() => value;
}

class _ReorderingSaveService implements SaveService {
  GameState? storedState;

  @override
  Future<SaveLoadResult> load() async => SaveLoaded(GameState.seeded());

  @override
  Future<void> save(GameState state) async {
    if (state.offlineRateSnapshotMicrocoinsPerMinute != null) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    storedState = state;
  }
}

class _RecordingAnalyticsService implements AnalyticsService {
  final List<GameplayAnalyticsEvent> events = [];

  @override
  Future<void> record(GameplayAnalyticsEvent event) async {
    events.add(event);
  }
}

class _FailingAnalyticsService implements AnalyticsService {
  @override
  Future<void> record(GameplayAnalyticsEvent event) async {
    throw StateError('offline');
  }
}

class _RecordingAudioService implements AudioService {
  final List<AudioPreferences> initialized = [];
  final List<AudioPreferences> updated = [];
  final List<AudioCue> cues = [];
  int pauseCount = 0;
  int resumeCount = 0;

  @override
  Future<void> initialize(AudioPreferences preferences) async {
    initialized.add(preferences);
  }

  @override
  Future<void> updatePreferences(AudioPreferences preferences) async {
    updated.add(preferences);
  }

  @override
  Future<void> pauseBackground() async => pauseCount++;

  @override
  Future<void> resumeBackground() async => resumeCount++;

  @override
  Future<void> play(AudioCue cue) async => cues.add(cue);

  @override
  Future<void> dispose() async {}
}
