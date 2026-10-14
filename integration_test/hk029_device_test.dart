import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/app/app.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HK-029 device smoke keeps core offline flow responsive', (
    tester,
  ) async {
    final saves = MemorySaveService(
      initialResult: SaveLoaded(
        GameState.seeded().copyWith(pendingRentMicrocoins: 2250000),
      ),
    );
    final stopwatch = Stopwatch()..start();

    await tester.pumpWidget(
      HantuKontrakanApp(saveService: saves, locale: const Locale('en')),
    );
    await tester.pump();
    for (
      var frame = 0;
      frame < 50 && find.byKey(const Key('game-loading')).evaluate().isNotEmpty;
      frame++
    ) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('game-loading')), findsNothing);
    for (var frame = 0; frame < 3; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('wallet-coins')), findsOneWidget);
    stopwatch.stop();
    final screenshot = await binding.takeScreenshot('iphone_home');
    expect(screenshot, isNotEmpty);
    stopwatch.start();

    await tester.tap(find.byKey(const Key('collect-rent')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(saves.storedState?.walletCoins, 202);

    await tester.tap(find.byKey(const Key('settings-button')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('privacy-settings-section')), findsOneWidget);
    expect(tester.takeException(), isNull);

    stopwatch.stop();
    if (kDebugMode) {
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 10)));
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 100));
    final settingsScreenshot = await binding.takeScreenshot('iphone_settings');
    expect(settingsScreenshot, isNotEmpty);
  });
}
