import 'dart:ui';

import 'package:flame/components.dart';

import '../../simulation/models/game_state.dart';
import '../../simulation/models/ghost.dart';
import '../../simulation/models/room.dart';
import '../components/room_component.dart';

class KontrakanWorld extends PositionComponent {
  KontrakanWorld({
    required this.state,
    required this.happinessFor,
    required this.onRoomTap,
    required this.onGhostTap,
    required this.roomLabelFor,
    required this.happinessLabelFor,
    required this.lockedLabel,
    this.cutawayImage,
    this.ghostAtlases = const {},
  });

  final GameState state;
  final int Function(String ghostId) happinessFor;
  final void Function(String roomId) onRoomTap;
  final void Function(String ghostId) onGhostTap;
  final String Function(String roomId) roomLabelFor;
  final String Function(int happiness) happinessLabelFor;
  final String lockedLabel;
  final Image? cutawayImage;
  final Map<GhostKind, Image> ghostAtlases;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_Backdrop(cutawayImage));
    addAll(createRoomComponents());
  }

  List<RoomComponent> createRoomComponents() => [
    for (final layout in _roomLayouts) _createRoom(layout),
  ];

  RoomComponent _createRoom(_RoomLayout layout) {
    final room = _findRoom(layout.id);
    final ghost = room.occupantId == null
        ? null
        : state.ghostById(room.occupantId!);
    return RoomComponent(
      roomId: layout.id,
      ghost: ghost,
      happiness: ghost == null ? null : happinessFor(ghost.id),
      roomLabel: roomLabelFor(layout.id),
      happinessLabel: ghost == null
          ? null
          : happinessLabelFor(happinessFor(ghost.id)),
      lockedLabel: lockedLabel,
      position: Vector2(8 + (layout.column * 174), 34 + (layout.row * 134)),
      ghostAtlas: ghost == null ? null : ghostAtlases[ghost.kind],
      usesCutawayArt: cutawayImage != null,
      locked: !room.unlocked,
      onTap: () => onRoomTap(layout.id),
      onGhostTap: ghost == null ? null : () => onGhostTap(ghost.id),
    );
  }

  RoomState _findRoom(String roomId) {
    for (final room in state.rooms) {
      if (room.id == roomId) return room;
    }
    final layout = _roomLayouts.firstWhere((room) => room.id == roomId);
    return RoomState(id: roomId, column: layout.column, row: layout.row);
  }
}

const _roomLayouts = [
  _RoomLayout(id: 'room_03', column: 0, row: 0),
  _RoomLayout(id: 'room_04', column: 1, row: 0),
  _RoomLayout(id: 'room_01', column: 0, row: 1),
  _RoomLayout(id: 'room_02', column: 1, row: 1),
];

class _RoomLayout {
  const _RoomLayout({
    required this.id,
    required this.column,
    required this.row,
  });

  final String id;
  final int column;
  final int row;
}

class _Backdrop extends PositionComponent {
  _Backdrop(this.cutawayImage) : super(size: Vector2(360, 360));

  final Image? cutawayImage;

  final Paint _sky = Paint()..color = const Color(0xFF17183B);
  final Paint _moon = Paint()..color = const Color(0xFFFFE6A7);
  final Paint _ground = Paint()..color = const Color(0xFF29233F);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final image = cutawayImage;
    if (image != null) {
      add(
        SpriteComponent(
          sprite: Sprite(image),
          position: Vector2(0, 45),
          size: Vector2(360, 270),
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _sky);
    if (cutawayImage == null) {
      canvas.drawCircle(const Offset(300, 48), 25, _moon);
    }
    canvas.drawRect(const Rect.fromLTWH(0, 304, 360, 56), _ground);
    super.render(canvas);
  }
}
