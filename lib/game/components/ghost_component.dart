import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../simulation/models/ghost.dart';

enum GhostAnimationState { idle, happy, angry, special }

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

  GhostAnimationState get animationState {
    if (ghost.specialActionActive) return GhostAnimationState.special;
    if (happiness >= 80) return GhostAnimationState.happy;
    if (happiness < 40) return GhostAnimationState.angry;
    return GhostAnimationState.idle;
  }

  Color get _bodyColor => switch (ghost.kind) {
    GhostKind.pocong => const Color(0xFFE8F4E1),
    GhostKind.kuntilanak => const Color(0xFFF6D9E7),
    GhostKind.tuyul => const Color(0xFF8ED09A),
    GhostKind.genderuwo => const Color(0xFFA88A73),
  };

  @override
  void update(double dt) {
    _elapsed += dt;
    angle = switch (animationState) {
      GhostAnimationState.idle => math.sin(_elapsed * 3) * 0.025,
      GhostAnimationState.happy => math.sin(_elapsed * 5) * 0.04,
      GhostAnimationState.angry => math.sin(_elapsed * 11) * 0.07,
      GhostAnimationState.special => _elapsed * 1.5,
    };
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final state = animationState;
    final bounce = switch (state) {
      GhostAnimationState.idle => math.sin(_elapsed * 2) * 1.5,
      GhostAnimationState.happy => math.sin(_elapsed * 5) * 4,
      GhostAnimationState.angry => 0.0,
      GhostAnimationState.special => math.sin(_elapsed * 7) * 3,
    };
    canvas.save();
    canvas.translate(0, bounce);
    final bodyPaint = Paint()
      ..color = state == GhostAnimationState.special
          ? Color.lerp(_bodyColor, const Color(0xFFFFD95A), 0.45)!
          : _bodyColor;
    final outline = Paint()
      ..color = state == GhostAnimationState.angry
          ? const Color(0xFFFF6B6B)
          : state == GhostAnimationState.special
          ? const Color(0xFFFFD95A)
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
    switch (state) {
      case GhostAnimationState.angry:
        canvas.drawArc(
          const Rect.fromLTWH(34, 61, 16, 10),
          math.pi,
          math.pi,
          false,
          outline,
        );
        break;
      case GhostAnimationState.happy:
        canvas.drawArc(
          const Rect.fromLTWH(34, 54, 16, 14),
          0,
          math.pi,
          false,
          outline,
        );
        final blush = Paint()..color = const Color(0x99FF7B9C);
        canvas.drawCircle(const Offset(22, 54), 4, blush);
        canvas.drawCircle(const Offset(62, 54), 4, blush);
        break;
      case GhostAnimationState.special:
        canvas.drawCircle(const Offset(42, 61), 6, outline);
        final sparkle = Paint()..color = const Color(0xFFFFF1A8);
        canvas.drawCircle(const Offset(8, 20), 4, sparkle);
        canvas.drawCircle(const Offset(75, 30), 3, sparkle);
        break;
      case GhostAnimationState.idle:
        canvas.drawLine(const Offset(36, 61), const Offset(48, 61), outline);
        break;
    }
    canvas.restore();
    super.render(canvas);
  }

  @override
  void onTapUp(TapUpEvent event) => onTap();
}
