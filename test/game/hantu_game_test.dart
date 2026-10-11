import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/game/world/kontrakan_world.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/systems/happiness_system.dart';

void main() {
  test('2x2 cutaway creates four selectable room IDs at fixed positions', () {
    final selectedRoomIds = <String>[];
    final state = GameState.seeded();
    final world = KontrakanWorld(
      state: state,
      happinessFor: (id) => HappinessSystem.happinessFor(state, id),
      onRoomTap: selectedRoomIds.add,
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
        'room_03': (8.0, 34.0),
        'room_04': (182.0, 34.0),
        'room_01': (8.0, 168.0),
        'room_02': (182.0, 168.0),
      },
    );

    for (final room in rooms) {
      room.select();
    }
    expect(selectedRoomIds, ['room_03', 'room_04', 'room_01', 'room_02']);
  });
}
