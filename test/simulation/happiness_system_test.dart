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

  test('non-adjacent rooms contribute no compatibility', () {
    final seed = GameState.seeded();
    final state = seed.copyWith(
      rooms: const [
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
      rooms: const [
        RoomState(id: 'left', column: -1, occupantId: 'tuyul_left'),
        RoomState(id: 'center', column: 0, occupantId: 'pocong_01'),
        RoomState(id: 'right', column: 1, occupantId: 'tuyul_right'),
      ],
      complaintResolved: false,
    );

    expect(HappinessSystem.compatibilityFor(state, 'pocong_01'), -20);
    expect(HappinessSystem.happinessFor(state, 'pocong_01'), 50);
  });
}
