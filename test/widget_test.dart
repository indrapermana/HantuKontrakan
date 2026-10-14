import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/app/app.dart';
import 'package:hantu_kontrakan/services/rewarded_ad_service.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';

void main() {
  testWidgets('complaint resolution visibly updates and persists state', (
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

  testWidgets('rewarded collect grants base and earned bonus exactly once', (
    tester,
  ) async {
    final state = GameState.seeded().copyWith(pendingRentMicrocoins: 2250000);
    final saves = MemorySaveService(initialResult: SaveLoaded(state));
    await tester.pumpWidget(
      HantuKontrakanApp(
        saveService: saves,
        rewardedAdService: _EarnedRewardedAdService(),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Watch test ad · 2 + 2 coins (3/3 left)'), findsOneWidget);
    await tester.tap(find.byKey(const Key('collect-rent-rewarded')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('204 Spirit Coins'), findsOneWidget);
    expect(find.text('Ad reward earned: +2 bonus coins'), findsOneWidget);
    expect(saves.storedState?.pendingRentMicrocoins, 250000);
    expect(saves.storedState?.completedRentClaimIds, hasLength(1));
    expect(saves.storedState?.completedRewardedRentClaimIds, hasLength(1));
    expect(saves.storedState?.rewardedRentBonusCount, 1);
  });

  testWidgets('new player completes the HK-021 tutorial vertical slice', (
    tester,
  ) async {
    final saves = MemorySaveService();
    await tester.pumpWidget(
      HantuKontrakanApp(saveService: saves, locale: const Locale('en')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('YOUR NEW KONTRAKAN'), findsOneWidget);
    await tester.tap(find.byKey(const Key('tutorial-openingStory-action')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('tutorial-placePocong-action')));
    await tester.pump();

    expect(saves.storedState?.roomById('room_01').occupantId, 'pocong_01');
    expect(find.text('Collect All · 10 coins'), findsOneWidget);
    await tester.tap(find.byKey(const Key('collect-rent')));
    await tester.pump();
    expect(saves.storedState?.walletCoins, 210);

    await tester.tap(find.byKey(const Key('tutorial-placeKuntilanak-action')));
    await tester.pump();
    expect(saves.storedState?.activeIncidentId, 'pak_rt_complaint');

    await tester.tap(find.byKey(const Key('incident-button')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('incident-choice-join_patrol')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('incident-outcome-continue')));
    await tester.pump();

    expect(find.text('MORE ROOMS AWAIT'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('tutorial-inspectLockedRoom-action')),
    );
    await tester.pump();
    expect(find.byKey(const Key('tutorial-panel')), findsNothing);
    expect(saves.storedState?.unscriptedIncidentsEnabled, isTrue);
  });

  testWidgets('completed mission reward is visible and claimable once', (
    tester,
  ) async {
    final saves = MemorySaveService();
    await tester.pumpWidget(
      HantuKontrakanApp(saveService: saves, locale: const Locale('en')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('tutorial-openingStory-action')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('tutorial-placePocong-action')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('missions-button')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('First Tenant'), findsOneWidget);
    await tester.tap(find.byKey(const Key('claim-mission-place_pocong')));
    await tester.pump();

    expect(find.text('225 Spirit Coins'), findsOneWidget);
    expect(find.text('Claimed'), findsOneWidget);
    expect(saves.storedState?.completedMissionIds, {'place_pocong'});
    expect(saves.storedState?.playerExperience, 25);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('claim-mission-place_pocong')),
          )
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

  testWidgets('incident previews effects, commits once, and shows outcome', (
    tester,
  ) async {
    final state = GameState.seeded().copyWith(
      activeIncidentId: 'electricity_outage',
    );
    final saves = MemorySaveService(initialResult: SaveLoaded(state));
    await tester.pumpWidget(
      HantuKontrakanApp(saveService: saves, locale: const Locale('id')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Insiden: Listrik Padam'), findsOneWidget);
    await tester.tap(find.byKey(const Key('incident-button')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Listrik Padam'), findsOneWidget);
    expect(
      find.text(
        'Kontrakan gelap. Beberapa penghuni justru terlihat lebih jelas.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Dampak: -25 koin'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('incident-choice-buy_emergency_lights')),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('INSIDEN SELESAI'), findsOneWidget);
    expect(
      find.textContaining(
        'Lampu menyala dan bayangan kembali berperilaku normal.',
      ),
      findsOneWidget,
    );
    expect(saves.storedState?.walletCoins, 175);
    expect(saves.storedState?.chaos, 37);
    expect(saves.storedState?.activeIncidentId, isNull);
    expect(saves.storedState?.completedIncidentResolutionIds, hasLength(1));

    await tester.tap(find.byKey(const Key('incident-outcome-continue')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('incident-button')), findsNothing);
    expect(saves.storedState?.walletCoins, 175);
  });
}

class _EarnedRewardedAdService implements RewardedAdService {
  @override
  Future<RewardedAdOutcome> showRewardedAd({
    required Future<void> Function() onRewardEarned,
  }) async {
    await onRewardEarned();
    await onRewardEarned();
    return RewardedAdOutcome.earned;
  }
}
