import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/app/app.dart';
import 'package:hantu_kontrakan/features/home/home_screen.dart';
import 'package:hantu_kontrakan/services/save_service.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, {Locale? locale}) async {
    await tester.pumpWidget(
      HantuKontrakanApp(saveService: MemorySaveService(), locale: locale),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('app starts on the named home route in Indonesian', (
    tester,
  ) async {
    await pumpApp(tester, locale: const Locale('id'));

    expect(find.text('200 Koin Arwah'), findsOneWidget);
    final homeContext = tester.element(find.byType(HomeScreen));
    expect(ModalRoute.of(homeContext)?.settings.name, '/');
  });

  testWidgets('English localization is wired through the app', (tester) async {
    await pumpApp(tester, locale: const Locale('en'));

    expect(find.text('200 Spirit Coins'), findsOneWidget);
    expect(find.text('Complaint: Pocong is bothered by Tuyul'), findsOneWidget);
  });

  test('platform manifests declare portrait-only presentation', () {
    final androidManifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final iosManifest = File('ios/Runner/Info.plist').readAsStringSync();

    expect(androidManifest, contains('android:screenOrientation="portrait"'));
    expect(iosManifest, isNot(contains('UIInterfaceOrientationLandscape')));
  });
}
