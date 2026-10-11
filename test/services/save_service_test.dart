import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('shared preferences save round-trips schema state', () async {
    SharedPreferences.setMockInitialValues({});
    final saves = SharedPreferencesSaveService();
    final state = GameState.seeded().copyWith(walletCoins: 123);

    await saves.save(state);
    final loaded = await saves.load();

    expect(loaded?.walletCoins, 123);
    expect(loaded?.schemaVersion, GameState.currentSchemaVersion);
  });

  test('corrupt save safely returns null', () async {
    SharedPreferences.setMockInitialValues({
      'hantu_kontrakan_p0_save': '{not json',
    });

    expect(await SharedPreferencesSaveService().load(), isNull);
  });
}
