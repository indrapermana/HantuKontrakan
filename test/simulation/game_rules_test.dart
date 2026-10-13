import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';

void main() {
  test('places an unassigned ghost only into a vacant room', () {
    final initial = _placementState();
    final placed = GameRules.placeGhost(initial, 'kuntilanak_01', 'room_03');

    expect(placed.roomById('room_03').occupantId, 'kuntilanak_01');
    expect(
      identical(
        GameRules.placeGhost(placed, 'kuntilanak_01', 'room_01'),
        placed,
      ),
      isTrue,
    );
    expect(
      identical(GameRules.placeGhost(initial, 'missing', 'room_03'), initial),
      isTrue,
    );
  });

  test('moves an assigned ghost into a vacancy atomically', () {
    final initial = _placementState();
    final moved = GameRules.moveGhost(initial, 'pocong_01', 'room_03');

    expect(moved.roomById('room_01').occupantId, isNull);
    expect(moved.roomById('room_03').occupantId, 'pocong_01');
    expect(_occupiedGhostIds(moved), hasLength(2));
  });

  test('occupied destination is a no-op without swap authorization', () {
    final initial = _placementState();

    expect(
      identical(GameRules.moveGhost(initial, 'pocong_01', 'room_02'), initial),
      isTrue,
    );
  });

  test('authorized swap is atomic and preserves one-to-one occupancy', () {
    final initial = _placementState();
    final swapped = GameRules.moveGhost(
      initial,
      'pocong_01',
      'room_02',
      allowSwap: true,
    );

    expect(swapped.roomById('room_01').occupantId, 'tuyul_01');
    expect(swapped.roomById('room_02').occupantId, 'pocong_01');
    expect(_occupiedGhostIds(swapped), hasLength(2));
  });

  test('invalid moves and swaps are identity-preserving no-ops', () {
    final initial = _placementState();

    expect(
      identical(GameRules.moveGhost(initial, 'missing', 'room_03'), initial),
      isTrue,
    );
    expect(
      identical(GameRules.moveGhost(initial, 'pocong_01', 'missing'), initial),
      isTrue,
    );
    expect(
      identical(GameRules.moveGhost(initial, 'pocong_01', 'room_01'), initial),
      isTrue,
    );
    expect(
      identical(
        GameRules.moveGhost(
          initial,
          'kuntilanak_01',
          'room_02',
          allowSwap: true,
        ),
        initial,
      ),
      isTrue,
    );
  });

  test('complaint choice applies exact effects only once', () {
    final initial = GameState.seeded();
    final resolved = GameRules.resolveComplaint(
      initial,
      ComplaintChoice.installSoundproofing,
      'resolution-1',
    );
    final replayed = GameRules.resolveComplaint(
      resolved,
      ComplaintChoice.installSoundproofing,
      'resolution-1',
    );

    expect(resolved.walletCoins, 150);
    expect(resolved.ghostById('pocong_01').eventHappinessModifier, 20);
    expect(resolved.complaintResolved, isTrue);
    expect(identical(replayed, resolved), isTrue);
  });
}

GameState _placementState() => GameState(
  schemaVersion: GameState.currentSchemaVersion,
  walletCoins: 200,
  ghosts: const [
    GhostState(id: 'pocong_01', kind: GhostKind.pocong),
    GhostState(id: 'tuyul_01', kind: GhostKind.tuyul),
    GhostState(id: 'kuntilanak_01', kind: GhostKind.kuntilanak),
  ],
  rooms: const [
    RoomState(id: 'room_01', column: 0, occupantId: 'pocong_01'),
    RoomState(id: 'room_02', column: 1, occupantId: 'tuyul_01'),
    RoomState(id: 'room_03', column: 2),
  ],
  complaintResolved: false,
);

Set<String> _occupiedGhostIds(GameState state) =>
    state.rooms.map((room) => room.occupantId).whereType<String>().toSet();
