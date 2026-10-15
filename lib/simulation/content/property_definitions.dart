import '../models/room.dart';

class PropertyDefinition {
  const PropertyDefinition({required this.id, required this.roomIds});

  final String id;
  final List<String> roomIds;
}

abstract final class PropertyDefinitions {
  static const firstPropertyId = 'kontrakan_pertama';
  static const secondPropertyId = 'kontrakan_pasar';

  static const all = <PropertyDefinition>[
    PropertyDefinition(
      id: firstPropertyId,
      roomIds: ['room_01', 'room_02', 'room_03', 'room_04'],
    ),
    PropertyDefinition(
      id: secondPropertyId,
      roomIds: [
        'pasar_room_01',
        'pasar_room_02',
        'pasar_room_03',
        'pasar_room_04',
      ],
    ),
  ];

  static List<RoomState> secondPropertyRooms() => [
    RoomState(id: 'pasar_room_01', column: 0, row: 1),
    RoomState(id: 'pasar_room_02', column: 1, row: 1),
    RoomState(id: 'pasar_room_03', column: 0, row: 0),
    RoomState(id: 'pasar_room_04', column: 1, row: 0),
  ];
}
