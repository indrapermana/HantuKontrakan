import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../simulation/models/ghost.dart';
import 'ghost_component.dart';

class RoomComponent extends PositionComponent with TapCallbacks {
  RoomComponent({
    required this.roomId,
    required this.ghost,
    required this.happiness,
    required this.roomLabel,
    required this.happinessLabel,
    required this.lockedLabel,
    required super.position,
    required this.onTap,
    this.onGhostTap,
    this.locked = false,
  }) : super(size: Vector2(170, 132));

  final String roomId;
  final GhostState? ghost;
  final int? happiness;
  final String roomLabel;
  final String? happinessLabel;
  final String lockedLabel;
  final void Function() onTap;
  final void Function()? onGhostTap;
  final bool locked;
  final Paint _wallPaint = Paint()..color = const Color(0xFF554572);
  final Paint _floorPaint = Paint()..color = const Color(0xFF8A6650);
  final Paint _windowPaint = Paint()..color = const Color(0xFFF4C86A);
  final Paint _lockedPaint = Paint()..color = const Color(0xB81B1730);
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
          position: Vector2(size.x / 2, 72),
          onTap: onGhostTap ?? onTap,
        )..scale = Vector2.all(0.72),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      _wallPaint,
    );
    canvas.drawRect(Rect.fromLTWH(0, size.y - 24, size.x, 24), _floorPaint);
    canvas.drawRect(const Rect.fromLTWH(16, 35, 30, 35), _windowPaint);
    _labelPaint.render(canvas, roomLabel, Vector2(10, 9));
    if (ghost != null) {
      _labelPaint.render(canvas, happinessLabel!, Vector2(10, 107));
    }
    if (locked) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
        _lockedPaint,
      );
      _labelPaint.render(canvas, lockedLabel, Vector2(48, 60));
    }
    super.render(canvas);
  }

  @override
  void onTapUp(TapUpEvent event) => select();

  void select() => onTap();
}
