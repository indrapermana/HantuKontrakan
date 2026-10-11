import 'dart:ui';

import 'package:flame/components.dart';

import '../../simulation/models/game_state.dart';
import '../components/room_component.dart';

class KontrakanWorld extends World {
  KontrakanWorld({
    required this.state,
    required this.happinessFor,
    required this.onRoomTap,
  });

  final GameState state;
  final int Function(String ghostId) happinessFor;
  final void Function(String roomId) onRoomTap;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_Backdrop());
    for (final room in state.rooms) {
      final ghost = room.occupantId == null
          ? null
          : state.ghostById(room.occupantId!);
      add(
        RoomComponent(
          room: room,
          ghost: ghost,
          happiness: ghost == null ? null : happinessFor(ghost.id),
          position: Vector2(8 + (room.column * 174), 94),
          onTap: () => onRoomTap(room.id),
        ),
      );
    }
  }
}

class _Backdrop extends PositionComponent {
  _Backdrop() : super(size: Vector2(360, 360));

  final Paint _sky = Paint()..color = const Color(0xFF17183B);
  final Paint _moon = Paint()..color = const Color(0xFFFFE6A7);
  final Paint _ground = Paint()..color = const Color(0xFF29233F);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _sky);
    canvas.drawCircle(const Offset(300, 48), 25, _moon);
    canvas.drawRect(const Rect.fromLTWH(0, 304, 360, 56), _ground);
    super.render(canvas);
  }
}
