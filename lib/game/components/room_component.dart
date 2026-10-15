import 'dart:ui' as ui;

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
    this.ghostAtlas,
    this.usesCutawayArt = false,
    this.onGhostTap,
    this.locked = false,
  }) : super(size: Vector2(170, 96));

  final String roomId;
  final GhostState? ghost;
  final int? happiness;
  final String roomLabel;
  final String? happinessLabel;
  final String lockedLabel;
  final void Function() onTap;
  final void Function()? onGhostTap;
  final ui.Image? ghostAtlas;
  final bool usesCutawayArt;
  final bool locked;
  final Paint _wallPaint = Paint()..color = const Color(0xFF554572);
  final Paint _floorPaint = Paint()..color = const Color(0xFF8A6650);
  final Paint _windowPaint = Paint()..color = const Color(0xFFF4C86A);
  final Paint _lockedPaint = Paint()..color = const Color(0xC91B1730);
  final Paint _platePaint = Paint()..color = const Color(0xE63A251F);
  final Paint _plateBorderPaint = Paint()
    ..color = const Color(0xFFFFD47A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  final TextPaint _roomLabelPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFE9B8),
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
    ),
  );
  final TextPaint _statusPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 10,
      fontWeight: FontWeight.w800,
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
          position: Vector2(size.x / 2, 60),
          onTap: onGhostTap ?? onTap,
          atlasImage: ghostAtlas,
        )..scale = Vector2.all(0.72),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    if (!usesCutawayArt) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
        _wallPaint,
      );
      canvas.drawRect(Rect.fromLTWH(0, size.y - 24, size.x, 24), _floorPaint);
      canvas.drawRect(const Rect.fromLTWH(16, 35, 30, 35), _windowPaint);
    }
    if (locked) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(5, 5, 160, 86),
          const Radius.circular(10),
        ),
        _lockedPaint,
      );
      _drawLock(canvas, const Offset(85, 31));
      _drawCenteredPlate(canvas, lockedLabel, 54);
    } else {
      _drawPlate(canvas, roomLabel, const Offset(18, 8), _roomLabelPaint);
      if (ghost != null) {
        final value = happiness ?? 0;
        _drawMoodPlate(canvas, happinessLabel!, value);
      }
    }
    super.render(canvas);
  }

  void _drawPlate(
    Canvas canvas,
    String text,
    Offset position,
    TextPaint paint,
  ) {
    final width = _estimatedTextWidth(text, 10) + 16;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.dx, position.dy, width, 22),
      const Radius.circular(11),
    );
    canvas.drawRRect(rect, _platePaint);
    canvas.drawRRect(rect, _plateBorderPaint);
    paint.render(canvas, text, Vector2(position.dx + 8, position.dy + 5));
  }

  void _drawMoodPlate(Canvas canvas, String text, int value) {
    final color = value >= 80
        ? const Color(0xFF42D879)
        : value < 40
        ? const Color(0xFFE95858)
        : const Color(0xFFFFC84A);
    final moodPaint = Paint()..color = color;
    final width = _estimatedTextWidth(text, 10) + 30;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, 88, width, 23),
      const Radius.circular(12),
    );
    canvas.drawRRect(rect, _platePaint);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(const Offset(29, 99.5), 5, moodPaint);
    _statusPaint.render(canvas, text, Vector2(39, 93));
  }

  void _drawCenteredPlate(Canvas canvas, String text, double y) {
    final width = _estimatedTextWidth(text, 10) + 22;
    _drawPlate(canvas, text, Offset((size.x - width) / 2, y), _roomLabelPaint);
  }

  void _drawLock(Canvas canvas, Offset center) {
    final lockPaint = Paint()
      ..color = const Color(0xFFFFD47A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawArc(
      Rect.fromCenter(center: center.translate(0, -6), width: 18, height: 18),
      3.14,
      3.14,
      false,
      lockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, 5), width: 25, height: 20),
        const Radius.circular(4),
      ),
      lockPaint,
    );
  }

  double _estimatedTextWidth(String text, double fontSize) =>
      text.runes.length * fontSize * 0.62;

  @override
  void onTapUp(TapUpEvent event) => select();

  void select() => onTap();
}
