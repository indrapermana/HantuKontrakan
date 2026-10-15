import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/app/app.dart';
import 'package:hantu_kontrakan/services/rewarded_ad_service.dart';
import 'package:hantu_kontrakan/services/privacy_consent_service.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/content/mission_definitions.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/models/tutorial_step.dart';
import 'package:hantu_kontrakan/widgets/game_panel.dart';

void main() {
  testWidgets(
    'privacy settings persist opt-ins and keep offline promise visible',
    (tester) async {
      final saves = MemorySaveService(
        initialResult: SaveLoaded(GameState.seeded()),
      );
      await tester.pumpWidget(
        HantuKontrakanApp(
          saveService: saves,
          privacyConsentService: _RequiredPrivacyConsentService(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('settings-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Privacy'), findsOneWidget);
      await tester.tap(find.byKey(const Key('privacy-settings-section')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.textContaining('offline game remains playable'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('ad-privacy-options')), findsOneWidget);
      expect(find.byKey(const Key('privacy-policy')), findsOneWidget);
      tester
          .widget<TextButton>(find.byKey(const Key('privacy-policy')))
          .onPressed!();
      await tester.pump();
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(
        find.textContaining('Game progress, economy state'),
        findsOneWidget,
      );
      await tester.tap(find.text('Close').last);
      await tester.pump();

      tester
          .widget<SwitchListTile>(find.byKey(const Key('analytics-consent')))
          .onChanged!(true);
      await tester.pump();
      tester
          .widget<SwitchListTile>(
            find.byKey(const Key('error-reporting-consent')),
          )
          .onChanged!(true);
      await tester.pump();

      expect(saves.storedState?.analyticsConsentGranted, isTrue);
      expect(saves.storedState?.errorReportingConsentGranted, isTrue);
    },
  );

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

    expect(find.text('200'), findsOneWidget);
    expect(find.text('Pocong 35'), findsOneWidget);

    await tester.tap(find.byKey(const Key('complaint-button')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const Key('choice-soundproof')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('150'), findsOneWidget);
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

    expect(find.text('202'), findsOneWidget);
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

    await tester.tap(find.byKey(const Key('collect-rent')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Watch test ad · 2 + 2 coins (3/3 left)'), findsOneWidget);
    await tester.tap(find.byKey(const Key('post-collect-rewarded-offer')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('204'), findsOneWidget);
    expect(find.text('Ad reward earned: +2 bonus coins'), findsOneWidget);
    expect(saves.storedState?.pendingRentMicrocoins, 250000);
    expect(saves.storedState?.completedRentClaimIds, hasLength(2));
    expect(saves.storedState?.completedRewardedRentClaimIds, hasLength(1));
    expect(saves.storedState?.rewardedRentBonusCount, 1);
  });

  testWidgets('room bubble collects only its room before collect all', (
    tester,
  ) async {
    final state = GameState.seeded().copyWith(
      pendingRentMicrocoinsByRoom: const {
        'room_01': 2250000,
        'room_02': 1750000,
      },
    );
    final saves = MemorySaveService(initialResult: SaveLoaded(state));
    await tester.pumpWidget(
      HantuKontrakanApp(saveService: saves, locale: const Locale('en')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('room-rent-room_01')), findsOneWidget);
    expect(find.byKey(const Key('room-rent-room_02')), findsOneWidget);
    await tester.tap(find.byKey(const Key('room-rent-room_01')));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Room 01 paid 2 coins.'), findsOneWidget);
    expect(saves.storedState?.walletCoins, 202);
    expect(saves.storedState?.pendingRentCoinsForRoom('room_01'), 0);
    expect(saves.storedState?.pendingRentCoinsForRoom('room_02'), 1);
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
    await tester.tap(find.text('Close'));
    await tester.pump();

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
    await tester.scrollUntilVisible(
      find.text('First Tenant'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('First Tenant'), findsOneWidget);
    tester
        .widget<GamePrimaryButton>(
          find.byKey(const Key('claim-mission-place_pocong')),
        )
        .onPressed!();
    await tester.pump();

    expect(find.text('225'), findsOneWidget);
    expect(find.text('Claimed'), findsOneWidget);
    expect(saves.storedState?.completedMissionIds, {'place_pocong'});
    expect(saves.storedState?.playerExperience, 25);
    expect(
      tester
          .widget<GamePrimaryButton>(
            find.byKey(const Key('claim-mission-place_pocong')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('missions show three daily actions and Chapter 1', (
    tester,
  ) async {
    final saves = MemorySaveService(
      initialResult: SaveLoaded(GameState.seeded()),
    );
    await tester.pumpWidget(
      HantuKontrakanApp(saveService: saves, locale: const Locale('en')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('missions-button')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text("TODAY'S TASKS"), findsOneWidget);
    expect(
      find.byKey(const Key('daily-goal-daily_collect_rent')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('daily-goal-daily_active_management')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('daily-goal-daily_tenant_request')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const Key('daily-goal-daily_tenant_request')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('daily-reward-chest')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('daily-reward-chest')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('CHAPTER 1 · FIRST KONTRAKAN'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('CHAPTER 1 · FIRST KONTRAKAN'), findsOneWidget);
    expect(saves.storedState?.dailyGoalDayKey, isNotNull);
  });

  testWidgets('unassigned tenant can be placed into unlocked Room 3', (
    tester,
  ) async {
    final seed = GameState.newGame();
    final state = seed.copyWith(
      playerLevel: 3,
      playerExperience: 250,
      tutorialStep: TutorialStep.completed,
      rooms: [
        RoomState(id: 'room_01', column: 0, row: 1, occupantId: 'pocong_01'),
        RoomState(
          id: 'room_02',
          column: 1,
          row: 1,
          occupantId: 'kuntilanak_01',
        ),
        RoomState(id: 'room_03', column: 0, row: 0),
        RoomState(id: 'room_04', column: 1, row: 0, unlocked: false),
      ],
    );
    final saves = MemorySaveService(initialResult: SaveLoaded(state));
    await tester.pumpWidget(
      HantuKontrakanApp(saveService: saves, locale: const Locale('en')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('ghosts-navigation')));
    await tester.pump(const Duration(milliseconds: 300));
    final tuyulTile = tester.widget<ListTile>(
      find.byKey(const Key('ghost-roster-tuyul_01')),
    );
    tuyulTile.onTap!();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('profile-assign-tenant')), findsOneWidget);

    tester
        .widget<ButtonStyleButton>(
          find.byKey(const Key('profile-assign-tenant')),
        )
        .onPressed!();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('assign-tuyul_01-room_03')), findsOneWidget);
    tester
        .widget<GameChoiceCard>(
          find.byKey(const Key('assign-tuyul_01-room_03')),
        )
        .onPressed();
    await tester.pump(const Duration(milliseconds: 300));

    expect(saves.storedState?.roomById('room_03').occupantId, 'tuyul_01');
  });

  testWidgets(
    'HUD resources explain progression and mission badge is truthful',
    (tester) async {
      final state = GameState.seeded().copyWith(
        completedMissionIds: MissionDefinitions.all
            .map((mission) => mission.id)
            .toSet(),
      );
      final saves = MemorySaveService(initialResult: SaveLoaded(state));
      await tester.pumpWidget(
        HantuKontrakanApp(saveService: saves, locale: const Locale('en')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('mission-notification-badge')), findsNothing);
      expect(find.byKey(const Key('action-center-button')), findsNothing);

      await tester.tap(find.byKey(const Key('player-level')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byKey(const Key('level-progress-panel')), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pump();

      await tester.tap(find.byKey(const Key('wallet-coins')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byKey(const Key('coin-info-panel')), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pump();

      await tester.tap(find.byKey(const Key('mystical-crystals')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byKey(const Key('crystal-info-panel')), findsOneWidget);
    },
  );

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

  testWidgets('portfolio unlocks and revisits a second playable property', (
    tester,
  ) async {
    final state = GameState(
      schemaVersion: GameState.currentSchemaVersion,
      walletCoins: 200,
      playerLevel: 5,
      playerExperience: 700,
      ghosts: const [
        GhostState(id: 'pocong_01', kind: GhostKind.pocong),
        GhostState(id: 'kuntilanak_01', kind: GhostKind.kuntilanak),
        GhostState(id: 'tuyul_01', kind: GhostKind.tuyul),
        GhostState(id: 'genderuwo_01', kind: GhostKind.genderuwo),
      ],
      rooms: [
        RoomState(id: 'room_01', column: 0, row: 1, occupantId: 'pocong_01'),
        RoomState(
          id: 'room_02',
          column: 1,
          row: 1,
          occupantId: 'kuntilanak_01',
        ),
        RoomState(id: 'room_03', column: 0, occupantId: 'tuyul_01'),
        RoomState(id: 'room_04', column: 1, occupantId: 'genderuwo_01'),
      ],
      complaintResolved: true,
    );
    final saves = MemorySaveService(initialResult: SaveLoaded(state));
    await tester.pumpWidget(
      HantuKontrakanApp(saveService: saves, locale: const Locale('en')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('shop-navigation')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Expansion ready — no purchase required.'),
      findsOneWidget,
    );
    tester
        .widget<GameChoiceCard>(find.byKey(const Key('unlock-second-property')))
        .onPressed();
    await tester.pump(const Duration(milliseconds: 300));
    expect(saves.storedState?.propertyRoomsById, hasLength(2));
    expect(saves.storedState?.walletCoins, 200);

    await tester.tap(find.byKey(const Key('shop-navigation')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Night Market Lodge'), findsOneWidget);
    tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'Visit'))
        .onPressed!();
    await tester.pump(const Duration(milliseconds: 300));
    expect(saves.storedState?.activePropertyId, 'kontrakan_pasar');
    expect(saves.storedState?.rooms.first.id, 'pasar_room_01');
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

class _RequiredPrivacyConsentService implements PrivacyConsentService {
  @override
  Future<bool> canRequestAds() async => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isPrivacyOptionsRequired() async => true;

  @override
  Future<void> showPrivacyOptions() async {}
}
