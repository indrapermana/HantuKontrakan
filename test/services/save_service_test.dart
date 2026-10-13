import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
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
    final state = GameState.seeded().copyWith(walletCoins: 123);

    await saves.save(state);
    final result = await saves.load();

    expect(result, isA<SaveLoaded>());
    final loaded = (result as SaveLoaded).state;
    expect(loaded.walletCoins, 123);
    expect(loaded.schemaVersion, GameState.currentSchemaVersion);
    expect(loaded.chaos, 40);
    expect(loaded.activeSimulationSeconds, 0);
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
