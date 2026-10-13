import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/systems/happiness_system.dart';

void main() {
  test('Pocong and Tuyul compatibility is directional', () {
    final state = GameState.seeded();

    expect(HappinessSystem.compatibilityFor(state, 'pocong_01'), -15);
    expect(HappinessSystem.compatibilityFor(state, 'tuyul_01'), -5);
    expect(HappinessSystem.happinessFor(state, 'pocong_01'), 35);
    expect(HappinessSystem.happinessFor(state, 'tuyul_01'), 45);
  });

  test('all directional compatibility values match the plan matrix', () {
    const expected = {
      GhostKind.pocong: {
        GhostKind.kuntilanak: 5,
        GhostKind.tuyul: -15,
        GhostKind.genderuwo: 10,
      },
      GhostKind.kuntilanak: {
        GhostKind.pocong: 10,
        GhostKind.tuyul: 5,
        GhostKind.genderuwo: -10,
      },
      GhostKind.tuyul: {
        GhostKind.pocong: -5,
        GhostKind.kuntilanak: 10,
        GhostKind.genderuwo: -15,
      },
      GhostKind.genderuwo: {
        GhostKind.pocong: 10,
        GhostKind.kuntilanak: -5,
        GhostKind.tuyul: -10,
      },
    };

    for (final resident in expected.entries) {
      for (final neighbor in resident.value.entries) {
        final state = _neighborState(resident.key, neighbor.key);
        expect(
          HappinessSystem.compatibilityFor(state, 'resident'),
          neighbor.value,
          reason: '${resident.key.name} affected by ${neighbor.key.name}',
        );
      }
    }
  });

  test('vertical rooms are adjacent while diagonal rooms are not', () {
    final vertical = _neighborState(
      GhostKind.pocong,
      GhostKind.tuyul,
      neighborColumn: 0,
      neighborRow: 1,
    );
    final diagonal = _neighborState(
      GhostKind.pocong,
      GhostKind.tuyul,
      neighborColumn: 1,
      neighborRow: 1,
    );

    expect(HappinessSystem.compatibilityFor(vertical, 'resident'), -15);
    expect(HappinessSystem.compatibilityFor(diagonal, 'resident'), 0);
  });

  test('non-adjacent rooms contribute no compatibility', () {
    final seed = GameState.seeded();
    final state = seed.copyWith(
      rooms: [
        RoomState(id: 'room_01', column: 0, occupantId: 'pocong_01'),
        RoomState(id: 'room_02', column: 2, occupantId: 'tuyul_01'),
      ],
    );

    expect(HappinessSystem.compatibilityFor(state, 'pocong_01'), 0);
    expect(HappinessSystem.happinessFor(state, 'pocong_01'), 50);
  });

  test('compatibility and event modifiers respect their caps', () {
    final state = GameState(
      schemaVersion: GameState.currentSchemaVersion,
      walletCoins: 0,
      ghosts: const [
        GhostState(
          id: 'pocong_01',
          kind: GhostKind.pocong,
          eventHappinessModifier: 99,
        ),
        GhostState(id: 'tuyul_left', kind: GhostKind.tuyul),
        GhostState(id: 'tuyul_right', kind: GhostKind.tuyul),
      ],
      rooms: [
        RoomState(id: 'left', column: -1, occupantId: 'tuyul_left'),
        RoomState(id: 'center', column: 0, occupantId: 'pocong_01'),
        RoomState(id: 'right', column: 1, occupantId: 'tuyul_right'),
      ],
      complaintResolved: false,
    );

    expect(HappinessSystem.compatibilityFor(state, 'pocong_01'), -20);
    expect(HappinessSystem.happinessFor(state, 'pocong_01'), 50);
  });

  test('room and furniture tag scores use concrete mappings and caps', () {
    final state = GameState(
      schemaVersion: GameState.currentSchemaVersion,
      walletCoins: 0,
      ghosts: const [
        GhostState(id: 'kuntilanak_01', kind: GhostKind.kuntilanak),
        GhostState(id: 'pocong_01', kind: GhostKind.pocong),
      ],
      rooms: [
        RoomState(
          id: 'matched',
          column: 0,
          occupantId: 'kuntilanak_01',
          roomTagLevels: const {'plant': 1, 'decorated': 1, 'quiet': 1},
          furnitureTags: const ['plant', 'decorated', 'shiny'],
        ),
        RoomState(
          id: 'mismatched',
          column: 2,
          occupantId: 'pocong_01',
          roomTagLevels: const {'plant': 2, 'decorated': 2, 'mystical': 2},
          furnitureTags: const [
            'plant',
            'decorated',
            'mystical',
            'sturdy',
            'shiny',
            'bright',
          ],
        ),
      ],
      complaintResolved: false,
    );

    expect(HappinessSystem.roomPreferenceFor(state, 'kuntilanak_01'), 15);
    expect(HappinessSystem.furniturePreferenceFor(state, 'kuntilanak_01'), 8);
    expect(HappinessSystem.happinessFor(state, 'kuntilanak_01'), 73);
    expect(HappinessSystem.roomPreferenceFor(state, 'pocong_01'), -20);
    expect(HappinessSystem.furniturePreferenceFor(state, 'pocong_01'), -10);
    expect(HappinessSystem.happinessFor(state, 'pocong_01'), 20);
  });

  test('empty environment tags are neutral', () {
    final state = GameState.seeded();

    expect(HappinessSystem.roomPreferenceFor(state, 'pocong_01'), 0);
    expect(HappinessSystem.furniturePreferenceFor(state, 'pocong_01'), 0);
    expect(HappinessSystem.happinessFor(state, 'pocong_01'), 35);
  });
}

GameState _neighborState(
  GhostKind resident,
  GhostKind neighbor, {
  int neighborColumn = 1,
  int neighborRow = 0,
}) => GameState(
  schemaVersion: GameState.currentSchemaVersion,
  walletCoins: 0,
  ghosts: [
    GhostState(id: 'resident', kind: resident),
    GhostState(id: 'neighbor', kind: neighbor),
  ],
  rooms: [
    RoomState(id: 'resident-room', column: 0, occupantId: 'resident'),
    RoomState(
      id: 'neighbor-room',
      column: neighborColumn,
      row: neighborRow,
      occupantId: 'neighbor',
    ),
  ],
  complaintResolved: false,
);
