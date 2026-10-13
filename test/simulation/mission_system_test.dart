import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/content/mission_definitions.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';
import 'package:hantu_kontrakan/simulation/systems/mission_system.dart';

void main() {
  test('defines ten ordered beginner missions with stable rewards', () {
    expect(MissionDefinitions.all.map((mission) => mission.id), [
      'place_pocong',
      'collect_first_rent',
      'place_kuntilanak',
      'resolve_first_incident',
      'upgrade_comfort',
      'furnish_room',
      'happy_tenant',
      'place_tuyul',
      'unlock_room_03',
      'reach_level_5',
    ]);
    expect(MissionDefinitions.all.map((mission) => mission.reward.experience), [
      25,
      25,
      50,
      50,
      75,
      75,
      100,
      150,
      250,
      250,
    ]);
    expect(
      MissionDefinitions.all.fold<int>(
        0,
        (total, mission) => total + mission.reward.mysticalCrystals,
      ),
      5,
    );
  });

  test('completed mission reward is atomic and cannot be claimed twice', () {
    var state = GameRules.continueTutorial(GameState.newGame());
    state = GameRules.placeGhost(state, 'pocong_01', 'room_01');
    final mission = MissionDefinitions.byId('place_pocong')!;
    expect(MissionSystem.isClaimable(state, mission), isTrue);

    final claimed = MissionSystem.claim(state, mission.id);
    final replayed = MissionSystem.claim(claimed, mission.id);

    expect(claimed.walletCoins, 225);
    expect(claimed.playerExperience, 25);
    expect(claimed.completedMissionIds, {'place_pocong'});
    expect(replayed, same(claimed));
  });

  test('incomplete, out-of-order, blank, and unknown claims are no-ops', () {
    final state = GameState.newGame();
    for (final missionId in [
      '',
      'unknown',
      'place_pocong',
      'collect_first_rent',
    ]) {
      expect(MissionSystem.claim(state, missionId), same(state));
    }
  });

  test('first two missions use persisted action evidence across reload', () {
    var state = GameRules.continueTutorial(GameState.newGame());
    state = GameRules.placeGhost(state, 'pocong_01', 'room_01');
    state = MissionSystem.claim(state, 'place_pocong');
    expect(MissionSystem.claim(state, 'collect_first_rent'), same(state));

    state = GameRules.collectAllRent(state, 'first-rent');
    final restored = GameState.fromJson(state.toJson());
    final claimed = MissionSystem.claim(restored, 'collect_first_rent');

    expect(claimed.walletCoins, 265);
    expect(claimed.playerExperience, 125);
    expect(claimed.playerLevel, 2);
    expect(claimed.completedMissionIds, {'place_pocong', 'collect_first_rent'});
  });

  test('all ten missions can be claimed in order from persisted evidence', () {
    final seed = GameState.newGame();
    var state = seed.copyWith(
      playerLevel: 2,
      playerExperience: 100,
      completedRentClaimIds: {'rent-evidence'},
      completedIncidentResolutionIds: {'incident-evidence'},
      ghosts: seed.ghosts
          .map(
            (ghost) => ghost.id == 'pocong_01'
                ? ghost.copyWith(eventHappinessModifier: 10)
                : ghost,
          )
          .toList(growable: false),
      rooms: [
        RoomState(
          id: 'room_01',
          column: 0,
          row: 1,
          occupantId: 'pocong_01',
          upgrades: const {RoomAttribute.comfort: 1},
          roomTagLevels: const {'quiet': 1},
          furnitureIds: const {FurnitureSlot.primary: 'bed'},
          furnitureTags: const ['quiet'],
        ),
        RoomState(
          id: 'room_02',
          column: 1,
          row: 1,
          occupantId: 'kuntilanak_01',
        ),
        RoomState(id: 'room_03', column: 0, row: 0, occupantId: 'tuyul_01'),
        RoomState(id: 'room_04', column: 1, row: 0, unlocked: false),
      ],
    );

    for (final mission in MissionDefinitions.all) {
      expect(
        MissionSystem.isClaimable(state, mission),
        isTrue,
        reason: mission.id,
      );
      state = MissionSystem.claim(state, mission.id);
    }

    expect(state.completedMissionIds, hasLength(10));
    expect(state.walletCoins, 920);
    expect(state.mysticalCrystals, 5);
    expect(state.playerExperience, 1150);
    expect(state.playerLevel, 6);
    final complete = state;
    for (final mission in MissionDefinitions.all) {
      expect(MissionSystem.claim(complete, mission.id), same(complete));
    }
  });
}
