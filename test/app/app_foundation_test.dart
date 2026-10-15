import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/app/app.dart';
import 'package:hantu_kontrakan/features/home/home_screen.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    Locale? locale,
    bool showDebugTools = false,
  }) async {
    await tester.pumpWidget(
      HantuKontrakanApp(
        saveService: MemorySaveService(),
        locale: locale,
        showDebugTools: showDebugTools,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('app starts on the named home route in Indonesian', (
    tester,
  ) async {
    await pumpApp(tester, locale: const Locale('id'));

    expect(find.text('200'), findsOneWidget);
    final homeContext = tester.element(find.byType(HomeScreen));
    expect(ModalRoute.of(homeContext)?.settings.name, '/');
  });

  testWidgets('English localization is wired through the app', (tester) async {
    await pumpApp(tester, locale: const Locale('en'));

    expect(find.text('200'), findsOneWidget);
    expect(find.text('YOUR NEW KONTRAKAN'), findsOneWidget);
  });

  testWidgets('language toggle updates dialogue and survives reload', (
    tester,
  ) async {
    final saves = MemorySaveService(
      initialResult: SaveLoaded(
        GameState.seeded().copyWith(
          languageCode: 'en',
          activeIncidentId: 'electricity_outage',
        ),
      ),
    );
    await tester.pumpWidget(HantuKontrakanApp(saveService: saves));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('200'), findsOneWidget);
    expect(find.text('Incident: Electricity Outage'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('language-id')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('200'), findsOneWidget);
    expect(find.text('Insiden: Listrik Padam'), findsOneWidget);
    expect(saves.storedState?.languageCode, 'id');

    await tester.tap(find.byKey(const Key('incident-button')));
    await tester.pump();
    expect(
      find.text(
        'Kontrakan gelap. Beberapa penghuni justru terlihat lebih jelas.',
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(HantuKontrakanApp(saveService: saves));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('200'), findsOneWidget);
  });

  testWidgets('audio settings are localized and persist mute controls', (
    tester,
  ) async {
    final saves = MemorySaveService(
      initialResult: SaveLoaded(GameState.seeded()),
    );
    await tester.pumpWidget(
      HantuKontrakanApp(saveService: saves, locale: const Locale('id')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('settings-button')));
    await tester.pump();
    expect(find.text('Pengaturan audio'), findsOneWidget);
    expect(find.text('Volume musik'), findsOneWidget);

    await tester.tap(find.byKey(const Key('music-muted')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sound-muted')));
    await tester.pump();
    tester
        .widget<SwitchListTile>(find.byKey(const Key('haptics-enabled')))
        .onChanged!(false);
    await tester.pump();
    tester
        .widget<SwitchListTile>(find.byKey(const Key('reduced-motion-enabled')))
        .onChanged!(true);
    await tester.pump();

    expect(saves.storedState?.musicMuted, isTrue);
    expect(saves.storedState?.soundMuted, isTrue);
    expect(saves.storedState?.hapticsEnabled, isFalse);
    expect(saves.storedState?.reducedMotionEnabled, isTrue);
  });

  test('platform manifests declare portrait-only presentation', () {
    final androidManifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final iosManifest = File('ios/Runner/Info.plist').readAsStringSync();

    expect(androidManifest, contains('android:screenOrientation="portrait"'));
    expect(iosManifest, isNot(contains('UIInterfaceOrientationLandscape')));
  });

  test('Android release identity uses the confirmed application ID', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final activity = File(
      'android/app/src/main/kotlin/com/indesyakaryadigital/'
      'hantu_kontrakan/MainActivity.kt',
    ).readAsStringSync();

    expect(
      gradle,
      contains('applicationId = "com.indesyakaryadigital.hantu_kontrakan"'),
    );
    expect(
      gradle,
      contains('namespace = "com.indesyakaryadigital.hantu_kontrakan"'),
    );
    expect(
      activity,
      contains('package com.indesyakaryadigital.hantu_kontrakan'),
    );
  });

  testWidgets('foreground session ticker advances and pauses simulation', (
    tester,
  ) async {
    final saves = MemorySaveService(
      initialResult: SaveLoaded(GameState.seeded()),
    );
    await tester.pumpWidget(HantuKontrakanApp(saveService: saves));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pump(const Duration(seconds: 10));
    await tester.pump();
    expect(saves.storedState?.activeSimulationSeconds, 10);
    expect(saves.storedState?.dailyGoalProgress['daily_active_management'], 10);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 10));
    expect(saves.storedState?.activeSimulationSeconds, 10);
  });

  testWidgets('debug HUD exposes state and supports tick and reset', (
    tester,
  ) async {
    await pumpApp(tester, locale: const Locale('id'), showDebugTools: true);

    expect(find.byKey(const Key('debug-hud')), findsOneWidget);
    expect(find.textContaining('Coins 200  Chaos 40  Tick 0'), findsOneWidget);
    expect(find.textContaining('P 50  T 50  Seed 20261011'), findsOneWidget);

    await tester.tap(find.byKey(const Key('debug-special')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);

    await tester.tap(find.byKey(const Key('debug-tick')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Tick 1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('debug-reset')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Coins 200  Chaos 40  Tick 0'), findsOneWidget);
  });
}
