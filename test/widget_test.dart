import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/app/app.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';

void main() {
  testWidgets('complaint resolution visibly updates and persists state', (
    tester,
  ) async {
    final saves = MemorySaveService();
    await tester.pumpWidget(
      HantuKontrakanApp(saveService: saves, locale: const Locale('id')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('200 Koin Arwah'), findsOneWidget);
    expect(find.text('Pocong 35'), findsOneWidget);

    await tester.tap(find.byKey(const Key('complaint-button')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const Key('choice-soundproof')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('150 Koin Arwah'), findsOneWidget);
    expect(find.text('Pocong 55'), findsOneWidget);
    expect(find.text('Keluhan selesai dan tersimpan'), findsOneWidget);
    expect(saves.storedState?.complaintResolved, isTrue);
  });

  testWidgets('collect all pays visible whole rent once and persists', (
    tester,
  ) async {
    final state = GameState.seeded().copyWith(pendingRentMicrocoins: 2250000);
    final saves = MemorySaveService(initialResult: SaveLoaded(state));
    await tester.pumpWidget(
      HantuKontrakanApp(saveService: saves, locale: const Locale('id')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Ambil Semua · 2 koin'), findsOneWidget);
    await tester.tap(find.byKey(const Key('collect-rent')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('202 Koin Arwah'), findsOneWidget);
    expect(find.text('Ambil Semua · 0 koin'), findsOneWidget);
    expect(saves.storedState?.pendingRentMicrocoins, 250000);
    expect(saves.storedState?.completedRentClaimIds, hasLength(1));
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('collect-rent')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('app lifecycle persists and consumes one offline snapshot', (
    tester,
  ) async {
    final saves = MemorySaveService();
    await tester.pumpWidget(
      HantuKontrakanApp(saveService: saves, locale: const Locale('id')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      saves.storedState?.offlineRateSnapshotMicrocoinsPerMinute,
      isNotNull,
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 100));
    final pendingAfterResume = saves.storedState?.pendingRentMicrocoins;
    expect(saves.storedState?.offlineRateSnapshotMicrocoinsPerMinute, isNull);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 100));
    expect(saves.storedState?.pendingRentMicrocoins, pendingAfterResume);
  });
}
