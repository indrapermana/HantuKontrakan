import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/game/hantu_game.dart';
import 'package:hantu_kontrakan/game/world/kontrakan_world.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/systems/happiness_system.dart';

void main() {
  test('camera frames the portrait world responsively from viewport width', () {
    final game = HantuGame(
      state: GameState.seeded(),
      onRoomTap: (_) {},
      onGhostTap: (_) {},
      roomLabelFor: (id) => id,
      happinessLabelFor: (value) => '$value',
      lockedLabel: 'locked',
    );
    game.onGameResize(Vector2(390, 650));

    expect(game.camera.viewfinder.anchor, Anchor.center);
    expect(game.camera.viewfinder.position.x, 180);
    expect(game.camera.viewfinder.position.y, 260);
    expect(game.camera.viewfinder.zoom, closeTo(390 / 330, 0.001));
  });

  test('2x2 cutaway creates four selectable room IDs at fixed positions', () {
    final selectedRoomIds = <String>[];
    final selectedGhostIds = <String>[];
    final state = GameState.seeded();
    final world = KontrakanWorld(
      state: state,
      happinessFor: (id) => HappinessSystem.happinessFor(state, id),
      onRoomTap: selectedRoomIds.add,
      onGhostTap: selectedGhostIds.add,
      roomLabelFor: (id) => id,
      happinessLabelFor: (value) => '$value',
      lockedLabel: 'locked',
    );

    final rooms = world.createRoomComponents();

    expect(rooms, hasLength(4));
    expect(rooms.map((room) => room.roomId).toSet(), {
      'room_01',
      'room_02',
      'room_03',
      'room_04',
    });
    expect(
      rooms.where((room) => room.locked).map((room) => room.roomId).toSet(),
      {'room_03', 'room_04'},
    );
    expect(
      {
        for (final room in rooms)
          room.roomId: (room.position.x, room.position.y),
      },
      {
        'room_03': (8.0, 190.0),
        'room_04': (182.0, 190.0),
        'room_01': (8.0, 270.0),
        'room_02': (182.0, 270.0),
      },
    );

    for (final room in rooms) {
      room.select();
    }
    expect(selectedRoomIds, ['room_03', 'room_04', 'room_01', 'room_02']);

    rooms.firstWhere((room) => room.roomId == 'room_01').onGhostTap!();
    expect(selectedGhostIds, ['pocong_01']);
  });
}
