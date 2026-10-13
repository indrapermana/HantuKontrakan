import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/constants/game_balance.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';
import 'package:hantu_kontrakan/simulation/systems/happiness_system.dart';
import 'package:hantu_kontrakan/simulation/systems/offline_earnings_system.dart';
import 'package:hantu_kontrakan/simulation/systems/rent_system.dart';

void main() {
  test('documented Pocong happiness example produces 85 then 70', () {
    final withGenderuwo = _workedPocongState();
    final withBothNeighbors = withGenderuwo.copyWith(
      ghosts: [
        ...withGenderuwo.ghosts,
        const GhostState(id: 'tuyul_01', kind: GhostKind.tuyul),
      ],
      rooms: [
        ...withGenderuwo.rooms,
        RoomState(id: 'right', column: 2, occupantId: 'tuyul_01'),
      ],
    );

    final first = HappinessSystem.breakdownFor(withGenderuwo, 'pocong_01');
    final second = HappinessSystem.breakdownFor(withBothNeighbors, 'pocong_01');

    expect(first.roomPreference, 15);
    expect(first.furniturePreference, 10);
    expect(first.compatibility, 10);
    expect(first.total, 85);
    expect(second.compatibility, -5);
    expect(second.total, 70);
  });

  test('documented Pocong rent example is exactly 18.1125 coins', () {
    final state = _workedPocongState(chaos: 42, comfortLevel: 1);

    expect(RentSystem.rentPerMinuteMicrocoinsFor(state, 'pocong_01'), 18112500);
  });

  test('documented upgrade and room unlock balance remains exact', () {
    expect(GameBalance.roomUpgradeCosts, {0: 100, 1: 200});
    expect(GameBalance.maximumRoomUpgradeLevel, 2);
    expect(GameBalance.roomUnlockCosts, {'room_03': 400, 'room_04': 800});
    expect(GameBalance.roomUnlockLevels, {'room_03': 3, 'room_04': 5});

    var state = GameState.seeded().copyWith(walletCoins: 300, playerLevel: 5);
    state = GameRules.upgradeRoom(state, 'room_01', RoomAttribute.comfort);
    state = GameRules.upgradeRoom(state, 'room_01', RoomAttribute.comfort);

    expect(state.walletCoins, 0);
    expect(state.roomById('room_01').levelFor(RoomAttribute.comfort), 2);
    expect(
      identical(
        GameRules.upgradeRoom(state, 'room_01', RoomAttribute.comfort),
        state,
      ),
      isTrue,
    );
  });

  test('documented offline earnings examples remain exact', () {
    final paused = GameState.seeded().copyWith(
      offlineRateSnapshotMicrocoinsPerMinute:
          40 * GameBalance.microcoinsPerCoin,
      lastOfflineAccrualTimestampMillis: 0,
    );
    final twoHours = OfflineEarningsSystem.resume(
      paused,
      120 * GameBalance.millisecondsPerMinute,
    );
    final fiveHours = OfflineEarningsSystem.resume(
      paused,
      300 * GameBalance.millisecondsPerMinute,
    );

    expect(
      twoHours.pendingRentMicrocoins,
      2400 * GameBalance.microcoinsPerCoin,
    );
    expect(
      fiveHours.pendingRentMicrocoins,
      4800 * GameBalance.microcoinsPerCoin,
    );
  });

  test('current JSON round-trip preserves deterministic continuation', () {
    final seed = GameState.seeded();
    final evolved = seed.copyWith(
      walletCoins: 987,
      chaos: 70,
      activeSimulationSeconds: 321,
      playerLevel: 5,
      reputation: 77,
      pendingRentMicrocoins: 12345678,
      rentAccrualRemainder: 37,
      completedRentClaimIds: const {'claim-a', 'claim-b'},
      abilityCooldownSeconds: const {'pocong_01': 123},
      offlineRateSnapshotMicrocoinsPerMinute: 42000000,
      lastOfflineAccrualTimestampMillis: 1791864000000,
      ghosts: seed.ghosts
          .map(
            (ghost) => ghost.id == 'pocong_01'
                ? ghost.copyWith(
                    eventHappinessModifier: 12,
                    specialActionActive: true,
                  )
                : ghost,
          )
          .toList(growable: false),
      rooms: seed.rooms
          .map(
            (room) => room.id == 'room_01'
                ? room.copyWith(
                    occupantId: room.occupantId,
                    upgrades: const {
                      RoomAttribute.comfort: 2,
                      RoomAttribute.silence: 1,
                    },
                    roomTagLevels: const {'decorated': 2, 'quiet': 1},
                    furnitureIds: const {
                      FurnitureSlot.primary: 'bed',
                      FurnitureSlot.decoration: 'plant',
                    },
                    furnitureTags: const {'quiet', 'plant'},
                  )
                : room,
          )
          .toList(growable: false),
      complaintResolved: true,
      resolutionId: 'serialized-resolution',
    );
    final json = jsonDecode(jsonEncode(evolved.toJson()));
    final restored = GameState.fromJson(json as Map<String, Object?>);

    expect(restored.toJson(), evolved.toJson());

    final continuedOriginal = GameRules.advanceSimulation(evolved, 60);
    final continuedRestored = GameRules.advanceSimulation(restored, 60);
    expect(continuedRestored.toJson(), continuedOriginal.toJson());

    final collectedOriginal = GameRules.collectAllRent(
      continuedOriginal,
      'post-round-trip',
    );
    final collectedRestored = GameRules.collectAllRent(
      continuedRestored,
      'post-round-trip',
    );
    expect(collectedRestored.toJson(), collectedOriginal.toJson());
  });
}

GameState _workedPocongState({int chaos = 0, int comfortLevel = 0}) =>
    GameState(
      schemaVersion: GameState.currentSchemaVersion,
      walletCoins: 0,
      chaos: chaos,
      ghosts: const [
        GhostState(id: 'pocong_01', kind: GhostKind.pocong),
        GhostState(id: 'genderuwo_01', kind: GhostKind.genderuwo),
      ],
      rooms: [
        RoomState(id: 'left', column: 0, occupantId: 'genderuwo_01'),
        RoomState(
          id: 'center',
          column: 1,
          occupantId: 'pocong_01',
          upgrades: comfortLevel == 0
              ? const {}
              : {RoomAttribute.comfort: comfortLevel},
          roomTagLevels: const {'quiet': 2},
          furnitureIds: const {FurnitureSlot.primary: 'bed'},
          furnitureTags: const {'quiet'},
        ),
      ],
      complaintResolved: false,
    );
