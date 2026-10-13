import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/features/home/detail_sheets.dart';
import 'package:hantu_kontrakan/l10n/app_localizations.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';

void main() {
  testWidgets('room sheet shows state-driven tenant and happiness actions', (
    tester,
  ) async {
    final state = _detailState();
    var profileOpened = false;
    var moveRequested = false;

    await tester.pumpWidget(
      _LocalizedHarness(
        child: RoomDetailsSheet(
          state: state,
          room: state.roomById('room_01'),
          onViewGhost: () => profileOpened = true,
          onMoveGhost: () => moveRequested = true,
          onUpgrade: (_) {},
          onEquipFurniture: (_, _) {},
        ),
      ),
    );

    expect(find.text('KAMAR 01'), findsOneWidget);
    expect(find.text('Penghuni: Pocong'), findsOneWidget);
    expect(find.text('Kebahagiaan: 70 (Nyaman)'), findsOneWidget);
    expect(find.text('Dasar: 50'), findsOneWidget);
    expect(find.text('Preferensi kamar: 15'), findsOneWidget);
    expect(find.text('Furnitur: 10'), findsOneWidget);
    expect(find.text('Tetangga: -15'), findsOneWidget);
    expect(find.text('Peristiwa: 10'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('view-ghost-profile')));
    await tester.tap(find.byKey(const Key('view-ghost-profile')));
    await tester.ensureVisible(find.byKey(const Key('move-tenant')));
    await tester.tap(find.byKey(const Key('move-tenant')));
    expect(profileOpened, isTrue);
    expect(moveRequested, isTrue);
  });

  testWidgets('vacant room sheet hides unavailable tenant actions', (
    tester,
  ) async {
    final state = _detailState();

    await tester.pumpWidget(
      _LocalizedHarness(
        child: RoomDetailsSheet(
          state: state,
          room: state.roomById('room_03'),
          onViewGhost: () {},
          onMoveGhost: () {},
          onUpgrade: (_) {},
          onEquipFurniture: (_, _) {},
        ),
      ),
    );

    expect(find.text('Penghuni: Kosong'), findsOneWidget);
    expect(find.byKey(const Key('view-ghost-profile')), findsNothing);
    expect(find.byKey(const Key('move-tenant')), findsNothing);
  });

  testWidgets('room upgrade and furniture controls expose valid actions', (
    tester,
  ) async {
    final state = _detailState();
    RoomAttribute? upgraded;
    (FurnitureSlot, String)? equipped;
    await tester.pumpWidget(
      _LocalizedHarness(
        child: RoomDetailsSheet(
          state: state,
          room: state.roomById('room_01'),
          onViewGhost: () {},
          onMoveGhost: () {},
          onUpgrade: (attribute) => upgraded = attribute,
          onEquipFurniture: (slot, id) => equipped = (slot, id),
        ),
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('upgrade-comfort')));
    await tester.tap(find.byKey(const Key('upgrade-comfort')));
    expect(upgraded, RoomAttribute.comfort);

    await tester.ensureVisible(find.byKey(const Key('furniture-primary')));
    await tester.tap(find.byKey(const Key('furniture-primary')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bed').last);
    expect(equipped, (FurnitureSlot.primary, 'bed'));
  });

  testWidgets('maxed and unaffordable room upgrades are disabled', (
    tester,
  ) async {
    final seed = _detailState();
    final room = RoomState(
      id: 'room_01',
      column: 0,
      occupantId: 'pocong_01',
      upgrades: const {RoomAttribute.silence: 2},
      roomTagLevels: const {'quiet': 2},
    );
    final state = seed.copyWith(
      walletCoins: 0,
      rooms: [room, seed.roomById('room_02'), seed.roomById('room_03')],
    );
    await tester.pumpWidget(
      _LocalizedHarness(
        child: RoomDetailsSheet(
          state: state,
          room: room,
          onViewGhost: () {},
          onMoveGhost: () {},
          onUpgrade: (_) {},
          onEquipFurniture: (_, _) {},
        ),
      ),
    );

    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('upgrade-silence')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('upgrade-comfort')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('damaged room shows persisted repair cost and action', (
    tester,
  ) async {
    final seed = _detailState();
    final room = seed
        .roomById('room_01')
        .copyWith(
          occupantId: 'pocong_01',
          repairRequired: true,
          upgrades: const {RoomAttribute.durability: 1},
        );
    final state = seed.copyWith(
      rooms: [room, seed.roomById('room_02'), seed.roomById('room_03')],
    );
    var repairRequested = false;

    await tester.pumpWidget(
      _LocalizedHarness(
        child: RoomDetailsSheet(
          state: state,
          room: room,
          onViewGhost: () {},
          onMoveGhost: () {},
          onUpgrade: (_) {},
          onEquipFurniture: (_, _) {},
          onRepair: () => repairRequested = true,
        ),
      ),
    );

    expect(find.text('Kamar perlu diperbaiki'), findsOneWidget);
    expect(find.text('Perbaiki · 80 koin'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('repair-room')));
    await tester.tap(find.byKey(const Key('repair-room')));
    expect(repairRequested, isTrue);
  });

  testWidgets('ghost profile shows definition, room, happiness and move', (
    tester,
  ) async {
    final state = _detailState();
    var moveRequested = false;

    await tester.pumpWidget(
      _LocalizedHarness(
        child: GhostProfileSheet(
          state: state,
          ghost: state.ghostById('pocong_01'),
          onMoveGhost: () => moveRequested = true,
        ),
      ),
    );

    expect(find.text('PROFIL Pocong'), findsOneWidget);
    expect(find.text('Si Pelompat Gelisah'), findsOneWidget);
    expect(find.text('Kamar saat ini: 01'), findsOneWidget);
    expect(find.text('Kebahagiaan: 70 (Nyaman)'), findsOneWidget);
    expect(find.text('Sewa dasar: 10 / menit'), findsOneWidget);
    expect(find.text('Suka: quiet'), findsOneWidget);
    expect(find.text('Tidak suka: Tuyul'), findsOneWidget);
    expect(
      find.text(
        'Kemampuan: Menemukan 30 koin setiap 10 menit aktif saat '
        'kebahagiaan 80+',
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(const Key('profile-move-tenant')));
    await tester.tap(find.byKey(const Key('profile-move-tenant')));
    expect(moveRequested, isTrue);
  });
}

GameState _detailState() => GameState(
  schemaVersion: GameState.currentSchemaVersion,
  walletCoins: 200,
  ghosts: const [
    GhostState(
      id: 'pocong_01',
      kind: GhostKind.pocong,
      eventHappinessModifier: 10,
    ),
    GhostState(id: 'tuyul_01', kind: GhostKind.tuyul),
  ],
  rooms: [
    RoomState(
      id: 'room_01',
      column: 0,
      occupantId: 'pocong_01',
      roomTagLevels: const {'quiet': 2},
      furnitureTags: const ['quiet'],
    ),
    RoomState(id: 'room_02', column: 1, occupantId: 'tuyul_01'),
    RoomState(id: 'room_03', column: 2),
  ],
  complaintResolved: false,
);

class _LocalizedHarness extends StatelessWidget {
  const _LocalizedHarness({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
