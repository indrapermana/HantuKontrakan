import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/content/property_definitions.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';
import 'package:hantu_kontrakan/simulation/systems/portfolio_system.dart';
import 'package:hantu_kontrakan/simulation/systems/room_tier_system.dart';
import 'package:hantu_kontrakan/simulation/systems/rent_system.dart';

void main() {
  test('second property unlock is free, deterministic, and revisitable', () {
    final firstRooms = [
      RoomState(id: 'room_01', column: 0, row: 1, occupantId: 'pocong_01'),
      RoomState(id: 'room_02', column: 1, row: 1, occupantId: 'kuntilanak_01'),
      RoomState(id: 'room_03', column: 0, occupantId: 'tuyul_01'),
      RoomState(id: 'room_04', column: 1, occupantId: 'genderuwo_01'),
    ];
    final initial = GameState(
      schemaVersion: GameState.currentSchemaVersion,
      walletCoins: 777,
      playerLevel: 5,
      playerExperience: 700,
      ghosts: const [
        GhostState(id: 'pocong_01', kind: GhostKind.pocong),
        GhostState(id: 'kuntilanak_01', kind: GhostKind.kuntilanak),
        GhostState(id: 'tuyul_01', kind: GhostKind.tuyul),
        GhostState(id: 'genderuwo_01', kind: GhostKind.genderuwo),
      ],
      rooms: firstRooms,
      complaintResolved: true,
    );

    expect(PortfolioSystem.canUnlockSecondProperty(initial), isTrue);
    final unlocked = PortfolioSystem.unlockSecondProperty(initial);
    expect(unlocked.walletCoins, 777);
    expect(unlocked.mysticalCrystals, 0);
    expect(
      unlocked.propertyRoomsById.keys,
      containsAll([
        PropertyDefinitions.firstPropertyId,
        PropertyDefinitions.secondPropertyId,
      ]),
    );
    expect(unlocked.ghosts.any((ghost) => ghost.id == 'pocong_02'), isTrue);
    expect(PortfolioSystem.unlockSecondProperty(unlocked), same(unlocked));

    var market = PortfolioSystem.switchProperty(
      unlocked,
      PropertyDefinitions.secondPropertyId,
    );
    market = GameRules.placeGhost(market, 'pocong_02', 'pasar_room_01');
    expect(market.roomById('pasar_room_01').occupantId, 'pocong_02');
    final earning = RentSystem.accrue(market, 60);
    expect(earning.pendingRentMicrocoinsForRoom('room_01'), greaterThan(0));
    expect(
      earning.pendingRentMicrocoinsForRoom('pasar_room_01'),
      greaterThan(0),
    );

    final restored = GameState.fromJson(earning.toJson());
    final firstAgain = PortfolioSystem.switchProperty(
      restored,
      PropertyDefinitions.firstPropertyId,
    );
    expect(firstAgain.rooms, hasLength(4));
    expect(firstAgain.roomById('room_04').occupantId, 'genderuwo_01');
    expect(
      firstAgain
          .propertyRoomsById[PropertyDefinitions.secondPropertyId]!
          .first
          .occupantId,
      'pocong_02',
    );
  });

  test('incomplete first property cannot unlock expansion', () {
    final state = GameState.seeded();
    expect(PortfolioSystem.canUnlockSecondProperty(state), isFalse);
    expect(PortfolioSystem.unlockSecondProperty(state), same(state));
  });

  test('crystal furniture is optional, owned, and reload safe', () {
    final initial = GameState.seeded().copyWith(mysticalCrystals: 3);
    final purchased = PortfolioSystem.purchaseFurniture(initial, 'moon_mirror');
    expect(purchased.mysticalCrystals, 0);
    expect(purchased.ownedFurnitureIds, contains('moon_mirror'));
    expect(
      PortfolioSystem.purchaseFurniture(purchased, 'moon_mirror'),
      same(purchased),
    );
    final equipped = GameRules.equipFurniture(
      purchased,
      'room_01',
      'moon_mirror',
      FurnitureSlot.decoration,
    );
    expect(
      equipped.roomById('room_01').furnitureIn(FurnitureSlot.decoration),
      'moon_mirror',
    );
    expect(
      GameState.fromJson(equipped.toJson()).ownedFurnitureIds,
      contains('moon_mirror'),
    );
  });

  test('unowned furniture cannot be equipped and housed stories persist', () {
    final initial = GameState.seeded().copyWith(ownedFurnitureIds: const {});
    expect(
      GameRules.equipFurniture(
        initial,
        'room_01',
        'bed',
        FurnitureSlot.primary,
      ),
      same(initial),
    );
    final story = PortfolioSystem.completeGhostStory(initial, 'pocong_01');
    expect(story.completedGhostStoryIds, {'pocong_01'});
    expect(GameState.fromJson(story.toJson()).completedGhostStoryIds, {
      'pocong_01',
    });
  });

  test('room tier derives only from room improvements', () {
    final tierOne = RoomState(id: 'a', column: 0);
    final tierTwo = RoomState(
      id: 'b',
      column: 0,
      upgrades: const {RoomAttribute.comfort: 2},
      furnitureIds: const {FurnitureSlot.primary: 'bed'},
    );
    final tierThree = RoomState(
      id: 'c',
      column: 0,
      upgrades: const {
        RoomAttribute.comfort: 2,
        RoomAttribute.silence: 2,
        RoomAttribute.durability: 2,
      },
      furnitureIds: const {FurnitureSlot.primary: 'bed'},
    );
    expect(RoomTierSystem.tierFor(tierOne), 1);
    expect(RoomTierSystem.tierFor(tierTwo), 2);
    expect(RoomTierSystem.tierFor(tierThree), 3);
  });

  test('schema 22 migrates into the first property with starter ownership', () {
    final legacy = <String, Object?>{...GameState.seeded().toJson()}
      ..['schemaVersion'] = 22
      ..remove('activePropertyId')
      ..remove('propertyRoomsById')
      ..remove('ownedFurnitureIds')
      ..remove('completedGhostStoryIds');
    final migrated = GameState.fromJson(legacy);
    expect(migrated.schemaVersion, 24);
    expect(migrated.activePropertyId, PropertyDefinitions.firstPropertyId);
    expect(migrated.propertyRoomsById, hasLength(1));
    expect(migrated.ownedFurnitureIds, contains('bed'));
  });

  test('schema 23 adds accessible feedback defaults', () {
    final legacy = <String, Object?>{...GameState.seeded().toJson()}
      ..['schemaVersion'] = 23
      ..remove('hapticsEnabled')
      ..remove('reducedMotionEnabled');
    final migrated = GameState.fromJson(legacy);
    expect(migrated.schemaVersion, 24);
    expect(migrated.hapticsEnabled, isTrue);
    expect(migrated.reducedMotionEnabled, isFalse);
  });
}
