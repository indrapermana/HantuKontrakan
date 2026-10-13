import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/constants/game_balance.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
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
      pendingRentMicrocoins: 12345678,
      rentAccrualRemainder: 37,
      completedRentClaimIds: const {'rent-claim-1'},
      offlineRateSnapshotMicrocoinsPerMinute: 42000000,
      lastOfflineAccrualTimestampMillis: 1791864000000,
      ghosts: seed.ghosts
          .map(
            (ghost) => ghost.id == 'pocong_01'
                ? ghost.copyWith(specialActionActive: true)
                : ghost,
          )
          .toList(growable: false),
      rooms: [
        RoomState(
          id: 'room_01',
          column: 0,
          row: 1,
          occupantId: 'pocong_01',
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
    expect(loaded.schemaVersion, GameState.currentSchemaVersion);
    expect(loaded.chaos, 40);
    expect(loaded.activeSimulationSeconds, 0);
    expect(loaded.pendingRentMicrocoins, 12345678);
    expect(loaded.rentAccrualRemainder, 37);
    expect(loaded.completedRentClaimIds, {'rent-claim-1'});
    expect(loaded.offlineRateSnapshotMicrocoinsPerMinute, 42000000);
    expect(loaded.lastOfflineAccrualTimestampMillis, 1791864000000);
    expect(loaded.ghostById('pocong_01').specialActionActive, isTrue);
    expect(loaded.roomById('room_01').row, 1);
    expect(loaded.roomById('room_01').levelFor(RoomAttribute.silence), 2);
    expect(loaded.roomById('room_01').roomTagLevels, {'quiet': 2});
    expect(loaded.roomById('room_01').furnitureTags, {'quiet', 'plant'});
    expect(
      loaded.roomById('room_01').furnitureIn(FurnitureSlot.primary),
      'bed',
    );
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
