import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/app/app.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('wallet-coins')), findsOneWidget);

    await tester.tap(find.byKey(const Key('collect-rent')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(saves.storedState?.walletCoins, 202);

    await tester.tap(find.byKey(const Key('settings-button')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('privacy-settings-section')), findsOneWidget);
    expect(tester.takeException(), isNull);

    stopwatch.stop();
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 10)));
  });
}
