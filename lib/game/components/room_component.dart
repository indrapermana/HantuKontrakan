import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../simulation/models/ghost.dart';
import '../../simulation/models/room.dart';
import 'ghost_component.dart';

class RoomComponent extends PositionComponent with TapCallbacks {
  RoomComponent({
    required this.room,
    required this.ghost,
    required this.happiness,
    required super.position,
    required this.onTap,
  }) : super(size: Vector2(170, 210));

  final RoomState room;
  final GhostState? ghost;
  final int? happiness;
  final void Function() onTap;
  final Paint _wallPaint = Paint()..color = const Color(0xFF554572);
  final Paint _floorPaint = Paint()..color = const Color(0xFF8A6650);
  final Paint _windowPaint = Paint()..color = const Color(0xFFF4C86A);
  final TextPaint _labelPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (ghost != null) {
      add(
        GhostComponent(
          ghost: ghost!,
          happiness: happiness!,
          position: Vector2(size.x / 2, 117),
          onTap: onTap,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      _wallPaint,
    );
    canvas.drawRect(Rect.fromLTWH(0, size.y - 34, size.x, 34), _floorPaint);
    canvas.drawRect(const Rect.fromLTWH(16, 38, 36, 44), _windowPaint);
    _labelPaint.render(
      canvas,
      room.id.replaceAll('_', ' ').toUpperCase(),
      Vector2(10, 9),
    );
    if (ghost != null) {
      _labelPaint.render(canvas, 'Bahagia $happiness', Vector2(10, 181));
    }
    super.render(canvas);
  }

  @override
  void onTapUp(TapUpEvent event) => onTap();
}
