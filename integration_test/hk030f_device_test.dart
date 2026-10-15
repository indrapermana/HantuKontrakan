import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/app/app.dart';
import 'package:hantu_kontrakan/services/audio_service.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HK-030-F device feedback remains lifecycle safe', (
    tester,
  ) async {
    final saves = MemorySaveService(
      initialResult: SaveLoaded(
        GameState.seeded().copyWith(
          pendingRentMicrocoins: 2250000,
          activeIncidentId: 'electricity_outage',
        ),
      ),
    );
    await tester.pumpWidget(
      HantuKontrakanApp(
        saveService: saves,
        audioService: AudioplayersAudioService(),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();
    for (
      var frame = 0;
      frame < 50 && find.byKey(const Key('game-loading')).evaluate().isNotEmpty;
      frame += 1
    ) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('game-loading')), findsNothing);

    await tester.tap(find.byKey(const Key('collect-rent')));
    for (
      var frame = 0;
      frame < 50 &&
          find.byKey(const Key('rent-collected-panel')).evaluate().isEmpty;
      frame += 1
    ) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('rent-collected-panel')), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('incident-button')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(
      find.byKey(const Key('incident-choice-buy_emergency_lights')),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(saves.storedState?.activeIncidentId, isNull);
    await tester.tap(find.byKey(const Key('incident-outcome-continue')));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('settings-button')));
    await tester.pump(const Duration(milliseconds: 500));
    tester
        .widget<SwitchListTile>(find.byKey(const Key('reduced-motion-enabled')))
        .onChanged!(true);
    await tester.pump(const Duration(milliseconds: 300));
    expect(saves.storedState?.reducedMotionEnabled, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 300));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    expect(
      await binding.takeScreenshot('hk030f_audio_feedback_settings'),
      isNotEmpty,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await Future<void>.delayed(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  });
}
