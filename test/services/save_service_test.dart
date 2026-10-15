import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/constants/game_balance.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/rewarded_rent_claim.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('missing save is distinguished from invalid data', () async {
    SharedPreferences.setMockInitialValues({});

    expect(await SharedPreferencesSaveService().load(), isA<SaveNotFound>());
  });

  test('shared preferences save round-trips schema state', () async {
    SharedPreferences.setMockInitialValues({});
    final saves = SharedPreferencesSaveService();
    final seed = GameState.seeded();
    final state = seed.copyWith(
      walletCoins: 123,
      playerLevel: 5,
      playerExperience: 800,
      mysticalCrystals: 4,
      languageCode: 'en',
      analyticsConsentGranted: true,
      errorReportingConsentGranted: true,
      musicMuted: true,
      soundMuted: true,
      musicVolume: 0.2,
      soundVolume: 0.6,
      reputation: 77,
      pendingRentMicrocoins: 12345678,
      rentAccrualRemainder: 37,
      completedRentClaimIds: const {
        'rent-claim-1',
        'reward-pending',
        'reward-done',
      },
      pendingRewardedRentClaim: const RewardedRentClaim(
        id: 'reward-pending',
        bonusCoins: 12,
        localDayKey: '2026-10-14',
      ),
      completedRewardedRentClaimIds: const {'reward-done'},
      rewardedRentBonusDayKey: '2026-10-14',
      rewardedRentBonusCount: 1,
      abilityCooldownSeconds: const {'pocong_01': 123},
      offlineRateSnapshotMicrocoinsPerMinute: 42000000,
      lastOfflineAccrualTimestampMillis: 1791864000000,
      activeIncidentId: 'electricity_outage',
      lastIncidentResolvedAtActiveSecond: 0,
      unscriptedIncidentSpawnTimes: const [0],
      recentIncidentIds: const ['electricity_outage'],
      completedIncidentResolutionIds: const {'incident-resolution-1'},
      incidentRandomState: 12345,
      completedRepairIds: const {'repair-1'},
      completedMissionIds: const {'place_pocong'},
      dailyGoalDayKey: '2026-10-15',
      dailyTenantRoomId: 'room_01',
      dailyGoalProgress: const {'daily_collect_rent': 1},
      completedDailyGoalIds: const {'daily_active_management'},
      dailyChestClaimed: false,
      ghosts: seed.ghosts
          .map(
            (ghost) => ghost.id == 'pocong_01'
                ? ghost.copyWith(
                    eventHappinessModifier: 12,
                    eventModifierExpiresAtActiveSecond: 654,
                    specialActionActive: true,
                  )
                : ghost,
          )
          .toList(growable: false),
      rooms: [
        RoomState(
          id: 'room_01',
          column: 0,
          row: 1,
          occupantId: 'pocong_01',
          repairRequired: true,
          upgrades: const {RoomAttribute.silence: 2},
          roomTagLevels: const {'quiet': 2},
          furnitureIds: const {
            FurnitureSlot.primary: 'bed',
            FurnitureSlot.decoration: 'plant',
          },
          furnitureTags: const ['quiet', 'plant'],
        ),
        seed.roomById('room_02'),
      ],
    );

    await saves.save(state);
    final result = await saves.load();

    expect(result, isA<SaveLoaded>());
    final loaded = (result as SaveLoaded).state;
    expect(loaded.walletCoins, 123);
    expect(loaded.playerLevel, 5);
    expect(loaded.playerExperience, 800);
    expect(loaded.mysticalCrystals, 4);
    expect(loaded.languageCode, 'en');
    expect(loaded.analyticsConsentGranted, isTrue);
    expect(loaded.errorReportingConsentGranted, isTrue);
    expect(loaded.musicMuted, isTrue);
    expect(loaded.soundMuted, isTrue);
    expect(loaded.musicVolume, 0.2);
    expect(loaded.soundVolume, 0.6);
    expect(loaded.reputation, 77);
    expect(loaded.schemaVersion, GameState.currentSchemaVersion);
    expect(loaded.chaos, 40);
    expect(loaded.activeSimulationSeconds, 0);
    expect(loaded.pendingRentMicrocoins, 12345678);
    expect(loaded.rentAccrualRemainder, 37);
    expect(loaded.completedRentClaimIds, {
      'rent-claim-1',
      'reward-pending',
      'reward-done',
    });
    expect(loaded.pendingRewardedRentClaim?.id, 'reward-pending');
    expect(loaded.pendingRewardedRentClaim?.bonusCoins, 12);
    expect(loaded.completedRewardedRentClaimIds, {'reward-done'});
    expect(loaded.rewardedRentBonusDayKey, '2026-10-14');
    expect(loaded.rewardedRentBonusCount, 1);
    expect(loaded.abilityCooldownSeconds, {'pocong_01': 123});
    expect(loaded.offlineRateSnapshotMicrocoinsPerMinute, 42000000);
    expect(loaded.lastOfflineAccrualTimestampMillis, 1791864000000);
    expect(loaded.activeIncidentId, 'electricity_outage');
    expect(loaded.lastIncidentResolvedAtActiveSecond, 0);
    expect(loaded.unscriptedIncidentSpawnTimes, [0]);
    expect(loaded.recentIncidentIds, ['electricity_outage']);
    expect(loaded.completedIncidentResolutionIds, {'incident-resolution-1'});
    expect(loaded.incidentRandomState, 12345);
    expect(loaded.completedRepairIds, {'repair-1'});
    expect(loaded.completedMissionIds, {'place_pocong'});
    expect(loaded.dailyGoalDayKey, '2026-10-15');
    expect(loaded.dailyTenantRoomId, 'room_01');
    expect(loaded.dailyGoalProgress, {'daily_collect_rent': 1});
    expect(loaded.completedDailyGoalIds, {'daily_active_management'});
    expect(loaded.dailyChestClaimed, isFalse);
    expect(loaded.roomById('room_01').repairRequired, isTrue);
    expect(loaded.ghostById('pocong_01').specialActionActive, isTrue);
    expect(loaded.ghostById('pocong_01').eventHappinessModifier, 12);
    expect(
      loaded.ghostById('pocong_01').eventModifierExpiresAtActiveSecond,
      654,
    );
    expect(loaded.roomById('room_01').row, 1);
    expect(loaded.roomById('room_01').levelFor(RoomAttribute.silence), 2);
    expect(loaded.roomById('room_01').roomTagLevels, {'quiet': 2});
    expect(loaded.roomById('room_01').furnitureTags, {'quiet', 'plant'});
    expect(
      loaded.roomById('room_01').furnitureIn(FurnitureSlot.primary),
      'bed',
    );
  });

  test('version 15 save migrates with device language preference', () async {
    final version15 = GameState.seeded().toJson()
      ..['schemaVersion'] = 15
      ..remove('languageCode');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version15),
    });

    final result = await SharedPreferencesSaveService().load();

    expect((result as SaveLoaded).state.languageCode, isNull);
  });

  test('version 16 save migrates with analytics disabled', () async {
    final version16 = GameState.seeded().toJson()
      ..['schemaVersion'] = 16
      ..remove('analyticsConsentGranted');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version16),
    });

    final result = await SharedPreferencesSaveService().load();

    expect((result as SaveLoaded).state.analyticsConsentGranted, isFalse);
  });

  test('version 17 save migrates with audible default settings', () async {
    final version17 = GameState.seeded().toJson()
      ..['schemaVersion'] = 17
      ..remove('musicMuted')
      ..remove('soundMuted')
      ..remove('musicVolume')
      ..remove('soundVolume');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version17),
    });

    final result = await SharedPreferencesSaveService().load();
    final migrated = (result as SaveLoaded).state;

    expect(migrated.musicMuted, isFalse);
    expect(migrated.soundMuted, isFalse);
    expect(migrated.musicVolume, 0.35);
    expect(migrated.soundVolume, 0.7);
  });

  test('version 18 save migrates with empty rewarded-ad claim state', () async {
    final version18 = GameState.seeded().toJson()
      ..['schemaVersion'] = 18
      ..remove('pendingRewardedRentClaim')
      ..remove('completedRewardedRentClaimIds')
      ..remove('rewardedRentBonusDayKey')
      ..remove('rewardedRentBonusCount');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version18),
    });

    final result = await SharedPreferencesSaveService().load();
    final migrated = (result as SaveLoaded).state;

    expect(migrated.pendingRewardedRentClaim, isNull);
    expect(migrated.completedRewardedRentClaimIds, isEmpty);
    expect(migrated.rewardedRentBonusDayKey, isNull);
    expect(migrated.rewardedRentBonusCount, 0);
  });

  test('version 19 save migrates with crash reporting disabled', () async {
    final version19 = GameState.seeded().toJson()
      ..['schemaVersion'] = 19
      ..remove('errorReportingConsentGranted');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version19),
    });

    final result = await SharedPreferencesSaveService().load();

    expect((result as SaveLoaded).state.errorReportingConsentGranted, isFalse);
  });

  test('version 20 global rent migrates into one deterministic room', () async {
    final version20 =
        GameState.seeded().copyWith(pendingRentMicrocoins: 3250000).toJson()
          ..['schemaVersion'] = 20
          ..remove('pendingRentMicrocoinsByRoom');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version20),
    });

    final result = await SharedPreferencesSaveService().load();
    final migrated = (result as SaveLoaded).state;

    expect(migrated.schemaVersion, GameState.currentSchemaVersion);
    expect(migrated.pendingRentMicrocoins, 3250000);
    expect(migrated.pendingRentMicrocoinsByRoom, {'room_01': 3250000});
  });

  test('version 21 save migrates with no active daily schedule', () async {
    final version21 = GameState.seeded().toJson()
      ..['schemaVersion'] = 21
      ..remove('dailyGoalDayKey')
      ..remove('dailyTenantRoomId')
      ..remove('dailyGoalProgress')
      ..remove('completedDailyGoalIds')
      ..remove('dailyChestClaimed');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version21),
    });

    final result = await SharedPreferencesSaveService().load();
    final migrated = (result as SaveLoaded).state;

    expect(migrated.schemaVersion, GameState.currentSchemaVersion);
    expect(migrated.dailyGoalDayKey, isNull);
    expect(migrated.dailyTenantRoomId, isNull);
    expect(migrated.dailyGoalProgress, isEmpty);
    expect(migrated.completedDailyGoalIds, isEmpty);
    expect(migrated.dailyChestClaimed, isFalse);
  });

  test('version 1 save migrates to current debug state defaults', () async {
    final version1 = GameState.seeded().toJson()
      ..['schemaVersion'] = 1
      ..remove('chaos')
      ..remove('activeSimulationSeconds');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version1),
    });

    final result = await SharedPreferencesSaveService().load();

    expect(result, isA<SaveLoaded>());
    final migrated = (result as SaveLoaded).state;
    expect(migrated.schemaVersion, GameState.currentSchemaVersion);
    expect(migrated.chaos, 40);
    expect(migrated.activeSimulationSeconds, 0);
  });

  test('version 2 save migrates ghost special state to inactive', () async {
    final version2 = GameState.seeded().toJson()..['schemaVersion'] = 2;
    for (final ghost in version2['ghosts']! as List<Object?>) {
      (ghost! as Map<String, Object?>).remove('specialActionActive');
    }
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version2),
    });

    final result = await SharedPreferencesSaveService().load();

    final migrated = (result as SaveLoaded).state;
    expect(migrated.schemaVersion, GameState.currentSchemaVersion);
    expect(
      migrated.ghosts.every((ghost) => !ghost.specialActionActive),
      isTrue,
    );
  });

  test('version 3 save migrates room environment fields to defaults', () async {
    final version3 = GameState.seeded().toJson()..['schemaVersion'] = 3;
    for (final room in version3['rooms']! as List<Object?>) {
      final json = room! as Map<String, Object?>;
      json.remove('row');
      json.remove('roomTagLevels');
      json.remove('furnitureTags');
    }
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version3),
    });

    final result = await SharedPreferencesSaveService().load();

    final migrated = (result as SaveLoaded).state;
    expect(migrated.schemaVersion, GameState.currentSchemaVersion);
    expect(migrated.rooms.every((room) => room.row == 0), isTrue);
    expect(migrated.rooms.every((room) => room.roomTagLevels.isEmpty), isTrue);
    expect(migrated.rooms.every((room) => room.furnitureTags.isEmpty), isTrue);
  });

  test('version 4 save adds player level and locked upper rooms', () async {
    final seed = GameState.seeded();
    final version4 = seed.toJson()
      ..['schemaVersion'] = 4
      ..remove('playerLevel')
      ..['rooms'] = seed.rooms
          .where((room) => room.id == 'room_01' || room.id == 'room_02')
          .map((room) {
            final json = room.toJson()
              ..remove('unlocked')
              ..remove('upgrades')
              ..remove('furnitureIds');
            return json;
          })
          .toList();
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version4),
    });

    final result = await SharedPreferencesSaveService().load();

    final migrated = (result as SaveLoaded).state;
    expect(migrated.playerLevel, GameBalance.initialPlayerLevel);
    expect(migrated.rooms, hasLength(4));
    expect(migrated.roomById('room_01').unlocked, isTrue);
    expect(migrated.roomById('room_03').unlocked, isFalse);
    expect(migrated.roomById('room_04').unlocked, isFalse);
  });

  test('version 5 save migrates rent accumulation to zero', () async {
    final version5 = GameState.seeded().toJson()
      ..['schemaVersion'] = 5
      ..remove('pendingRentMicrocoins')
      ..remove('rentAccrualRemainder');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version5),
    });

    final result = await SharedPreferencesSaveService().load();

    final migrated = (result as SaveLoaded).state;
    expect(migrated.pendingRentMicrocoins, 0);
    expect(migrated.rentAccrualRemainder, 0);
  });

  test('version 6 save migrates completed rent claims to empty', () async {
    final version6 = GameState.seeded().toJson()
      ..['schemaVersion'] = 6
      ..remove('completedRentClaimIds');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version6),
    });

    final result = await SharedPreferencesSaveService().load();

    final migrated = (result as SaveLoaded).state;
    expect(migrated.completedRentClaimIds, isEmpty);
  });

  test('version 7 save migrates offline snapshot to empty', () async {
    final version7 = GameState.seeded().toJson()
      ..['schemaVersion'] = 7
      ..remove('offlineRateSnapshotMicrocoinsPerMinute')
      ..remove('lastOfflineAccrualTimestampMillis');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version7),
    });

    final result = await SharedPreferencesSaveService().load();

    final migrated = (result as SaveLoaded).state;
    expect(migrated.offlineRateSnapshotMicrocoinsPerMinute, isNull);
    expect(migrated.lastOfflineAccrualTimestampMillis, isNull);
  });

  test('version 8 save migrates reputation and ability cooldowns', () async {
    final version8 = GameState.seeded().toJson()
      ..['schemaVersion'] = 8
      ..remove('reputation')
      ..remove('abilityCooldownSeconds');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version8),
    });

    final result = await SharedPreferencesSaveService().load();

    final migrated = (result as SaveLoaded).state;
    expect(migrated.reputation, GameBalance.initialReputation);
    expect(migrated.abilityCooldownSeconds, isEmpty);
  });

  test('version 9 save migrates event modifier expiry to empty', () async {
    final version9 = GameState.seeded().toJson()..['schemaVersion'] = 9;
    for (final ghost in version9['ghosts']! as List<Object?>) {
      (ghost! as Map<String, Object?>).remove(
        'eventModifierExpiresAtActiveSecond',
      );
    }
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version9),
    });

    final result = await SharedPreferencesSaveService().load();

    final migrated = (result as SaveLoaded).state;
    expect(
      migrated.ghosts.every(
        (ghost) => ghost.eventModifierExpiresAtActiveSecond == null,
      ),
      isTrue,
    );
  });

  test('version 10 save migrates incident scheduler defaults', () async {
    final version10 = GameState.seeded().toJson()
      ..['schemaVersion'] = 10
      ..remove('unscriptedIncidentsEnabled')
      ..remove('activeIncidentId')
      ..remove('lastIncidentResolvedAtActiveSecond')
      ..remove('unscriptedIncidentSpawnTimes')
      ..remove('recentIncidentIds')
      ..remove('completedIncidentResolutionIds')
      ..remove('incidentRandomState');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version10),
    });

    final result = await SharedPreferencesSaveService().load();
    final migrated = (result as SaveLoaded).state;

    expect(migrated.schemaVersion, GameState.currentSchemaVersion);
    expect(migrated.unscriptedIncidentsEnabled, isTrue);
    expect(migrated.activeIncidentId, isNull);
    expect(migrated.unscriptedIncidentSpawnTimes, isEmpty);
    expect(migrated.completedIncidentResolutionIds, isEmpty);
    expect(migrated.incidentRandomState, GameBalance.defaultRandomSeed);
  });

  test('version 11 save migrates repair state defaults', () async {
    final version11 = GameState.seeded().toJson()
      ..['schemaVersion'] = 11
      ..remove('completedRepairIds');
    for (final room in version11['rooms']! as List<Object?>) {
      (room! as Map<String, Object?>).remove('repairRequired');
    }
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version11),
    });

    final result = await SharedPreferencesSaveService().load();
    final migrated = (result as SaveLoaded).state;

    expect(migrated.schemaVersion, GameState.currentSchemaVersion);
    expect(migrated.completedRepairIds, isEmpty);
    expect(migrated.rooms.every((room) => !room.repairRequired), isTrue);
  });

  test('version 13 save derives experience from its persisted level', () async {
    final version13 = GameState.seeded().copyWith(playerLevel: 5).toJson()
      ..['schemaVersion'] = 13
      ..remove('playerExperience');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version13),
    });

    final result = await SharedPreferencesSaveService().load();
    final migrated = (result as SaveLoaded).state;

    expect(migrated.schemaVersion, GameState.currentSchemaVersion);
    expect(migrated.playerLevel, 5);
    expect(migrated.playerExperience, 700);
  });

  test('version 14 save preserves XP and adds empty mission rewards', () async {
    final version14 =
        GameState.seeded()
            .copyWith(playerLevel: 3, playerExperience: 300)
            .toJson()
          ..['schemaVersion'] = 14
          ..remove('mysticalCrystals')
          ..remove('completedMissionIds');
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: jsonEncode(version14),
    });

    final result = await SharedPreferencesSaveService().load();
    final migrated = (result as SaveLoaded).state;

    expect(migrated.playerLevel, 3);
    expect(migrated.playerExperience, 300);
    expect(migrated.mysticalCrystals, 0);
    expect(migrated.completedMissionIds, isEmpty);
  });

  test('corrupt save is rejected and preserved as a backup', () async {
    const corruptPayload = '{not json';
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: corruptPayload,
    });

    final result = await SharedPreferencesSaveService().load();
    final preferences = await SharedPreferences.getInstance();

    expect(
      result,
      isA<SaveRejected>().having(
        (value) => value.reason,
        'reason',
        SaveRejectionReason.corrupt,
      ),
    );
    expect(
      preferences.getString(SharedPreferencesSaveService.saveKey),
      corruptPayload,
    );
    expect(
      preferences.getString(SharedPreferencesSaveService.rejectedSaveBackupKey),
      corruptPayload,
    );
  });

  test('unsupported schema is reported deliberately and preserved', () async {
    final unsupportedPayload = jsonEncode({'schemaVersion': 99});
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSaveService.saveKey: unsupportedPayload,
    });

    final result = await SharedPreferencesSaveService().load();
    final preferences = await SharedPreferences.getInstance();

    expect(
      result,
      isA<SaveRejected>()
          .having(
            (value) => value.reason,
            'reason',
            SaveRejectionReason.unsupportedVersion,
          )
          .having((value) => value.schemaVersion, 'schemaVersion', 99),
    );
    expect(
      preferences.getString(SharedPreferencesSaveService.rejectedSaveBackupKey),
      unsupportedPayload,
    );
  });

  test(
    'missing or malformed schema is corrupt rather than unsupported',
    () async {
      SharedPreferences.setMockInitialValues({
        SharedPreferencesSaveService.saveKey: jsonEncode({'walletCoins': 10}),
      });

      final result = await SharedPreferencesSaveService().load();

      expect(
        result,
        isA<SaveRejected>().having(
          (value) => value.reason,
          'reason',
          SaveRejectionReason.corrupt,
        ),
      );
    },
  );
}
