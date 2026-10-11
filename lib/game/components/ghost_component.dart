import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../simulation/models/ghost.dart';

class GhostComponent extends PositionComponent with TapCallbacks {
  GhostComponent({
    required this.ghost,
    required this.happiness,
    required super.position,
    required this.onTap,
  }) : super(size: Vector2(82, 100), anchor: Anchor.center);

  final GhostState ghost;
  final int happiness;
  final void Function() onTap;
  double _elapsed = 0;

  Color get _bodyColor => switch (ghost.kind) {
    GhostKind.pocong => const Color(0xFFE8F4E1),
    GhostKind.tuyul => const Color(0xFF8ED09A),
  };

  @override
  void update(double dt) {
    _elapsed += dt;
    angle = math.sin(_elapsed * (happiness < 40 ? 8 : 3)) * 0.035;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final bodyPaint = Paint()..color = _bodyColor;
    final outline = Paint()
      ..color = happiness < 40
          ? const Color(0xFFFF6B6B)
          : const Color(0xFF402F55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(10, 8, 62, 84),
      const Radius.circular(28),
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, outline);
    final eyePaint = Paint()..color = const Color(0xFF241C35);
    canvas.drawCircle(const Offset(31, 42), 4, eyePaint);
    canvas.drawCircle(const Offset(53, 42), 4, eyePaint);
    final mouth = happiness < 40
        ? const Rect.fromLTWH(34, 59, 16, 10)
        : const Rect.fromLTWH(34, 55, 16, 13);
    canvas.drawArc(mouth, 0, math.pi, happiness < 40, outline);
    super.render(canvas);
  }

  @override
  void onTapUp(TapUpEvent event) => onTap();
}
