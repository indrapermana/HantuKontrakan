import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/constants/game_balance.dart';
import 'package:hantu_kontrakan/simulation/content/furniture_definitions.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';
import 'package:hantu_kontrakan/simulation/systems/happiness_system.dart';

void main() {
  test('room unlock enforces level, price and non-negative wallet', () {
    final seed = GameState.seeded();
    final underLevel = seed.copyWith(walletCoins: 1000, playerLevel: 2);
    final underfunded = seed.copyWith(walletCoins: 399, playerLevel: 3);

    expect(
      identical(GameRules.unlockRoom(underLevel, 'room_03'), underLevel),
      isTrue,
    );
    expect(
      identical(GameRules.unlockRoom(underfunded, 'room_03'), underfunded),
      isTrue,
    );

    final eligible = seed.copyWith(walletCoins: 400, playerLevel: 3);
    final unlocked = GameRules.unlockRoom(eligible, 'room_03');
    expect(unlocked.roomById('room_03').unlocked, isTrue);
    expect(unlocked.walletCoins, 0);
    expect(
      identical(GameRules.unlockRoom(unlocked, 'room_03'), unlocked),
      isTrue,
    );
  });

  test('upgrade costs scale, stop at max and update preference tags', () {
    var state = GameState.seeded().copyWith(walletCoins: 300);

    state = GameRules.upgradeRoom(state, 'room_01', RoomAttribute.silence);
    expect(state.walletCoins, 200);
    expect(state.roomById('room_01').levelFor(RoomAttribute.silence), 1);
    expect(state.roomById('room_01').roomTagLevels['quiet'], 1);
    expect(HappinessSystem.roomPreferenceFor(state, 'pocong_01'), 10);

    state = GameRules.upgradeRoom(state, 'room_01', RoomAttribute.silence);
    expect(state.walletCoins, 0);
    expect(state.roomById('room_01').levelFor(RoomAttribute.silence), 2);
    expect(state.roomById('room_01').roomTagLevels['quiet'], 2);
    expect(HappinessSystem.roomPreferenceFor(state, 'pocong_01'), 15);

    final maxed = state;
    expect(
      identical(
        GameRules.upgradeRoom(maxed, 'room_01', RoomAttribute.silence),
        maxed,
      ),
      isTrue,
    );
    expect(maxed.walletCoins, isNonNegative);
  });

  test('locked room upgrades and tenant moves are no-ops', () {
    final state = GameState.seeded().copyWith(walletCoins: 1000);

    expect(
      identical(
        GameRules.upgradeRoom(state, 'room_03', RoomAttribute.comfort),
        state,
      ),
      isTrue,
    );
    expect(
      identical(GameRules.moveGhost(state, 'pocong_01', 'room_03'), state),
      isTrue,
    );
  });

  test('furniture respects slot and replaces its derived tags atomically', () {
    var state = GameState.seeded();

    expect(
      identical(
        GameRules.equipFurniture(
          state,
          'room_01',
          'plant',
          FurnitureSlot.primary,
        ),
        state,
      ),
      isTrue,
    );

    state = GameRules.equipFurniture(
      state,
      'room_01',
      'bed',
      FurnitureSlot.primary,
    );
    state = GameRules.equipFurniture(
      state,
      'room_01',
      'plant',
      FurnitureSlot.decoration,
    );
    var room = state.roomById('room_01');
    expect(room.furnitureIds, {
      FurnitureSlot.primary: 'bed',
      FurnitureSlot.decoration: 'plant',
    });
    expect(room.furnitureTags, {'quiet', 'plant'});

    state = GameRules.equipFurniture(
      state,
      'room_01',
      'lamp',
      FurnitureSlot.primary,
    );
    room = state.roomById('room_01');
    expect(room.furnitureIn(FurnitureSlot.primary), 'lamp');
    expect(room.furnitureTags, {'shiny', 'plant'});
  });

  test('all furniture definitions are available across two slots', () {
    expect(FurnitureDefinitions.all, hasLength(14));
    expect(
      FurnitureDefinitions.all.values.where(
        (item) => item.slot == FurnitureSlot.primary,
      ),
      hasLength(7),
    );
    expect(
      FurnitureDefinitions.all.values.where(
        (item) => item.slot == FurnitureSlot.decoration,
      ),
      hasLength(7),
    );
    expect(GameBalance.maximumRoomUpgradeLevel, 2);
    expect(GameBalance.roomUpgradeCosts, {0: 100, 1: 200});
  });
}
