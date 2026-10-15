import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/game_feedback_service.dart';

class GameFeedbackOverlay extends StatelessWidget {
  const GameFeedbackOverlay({
    required this.signal,
    required this.reducedMotion,
    super.key,
  });

  final GameFeedbackSignal? signal;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final current = signal;
    if (current == null) return const SizedBox.shrink();
    final color = switch (current.kind) {
      GameFeedbackKind.warning => const Color(0xFFFF6B5E),
      GameFeedbackKind.coin ||
      GameFeedbackKind.reward => const Color(0xFFFFD35A),
      GameFeedbackKind.unlock => const Color(0xFF62E58A),
      GameFeedbackKind.upgrade => const Color(0xFF75C9FF),
      GameFeedbackKind.tenant => const Color(0xFFC998FF),
    };
    final icon = switch (current.kind) {
      GameFeedbackKind.coin => Icons.monetization_on_rounded,
      GameFeedbackKind.upgrade => Icons.arrow_upward_rounded,
      GameFeedbackKind.unlock => Icons.lock_open_rounded,
      GameFeedbackKind.reward => Icons.auto_awesome_rounded,
      GameFeedbackKind.warning => Icons.crisis_alert_rounded,
      GameFeedbackKind.tenant => Icons.sentiment_very_satisfied_rounded,
    };
    return IgnorePointer(
      child: Center(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(current.sequence),
          tween: Tween(begin: 0, end: 1),
          duration: reducedMotion
              ? const Duration(milliseconds: 300)
              : const Duration(milliseconds: 900),
          builder: (context, progress, child) {
            final fade = (1 - progress).clamp(0.0, 1.0);
            final rise = reducedMotion ? 0.0 : -42 * progress;
            return Opacity(
              opacity: fade,
              child: Transform.translate(
                offset: Offset(0, rise),
                child: SizedBox.square(
                  dimension: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!reducedMotion)
                        for (var index = 0; index < 8; index += 1)
                          Transform.translate(
                            offset: Offset(
                              math.cos(index * math.pi / 4) * 42 * progress,
                              math.sin(index * math.pi / 4) * 42 * progress,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: const SizedBox.square(dimension: 7),
                            ),
                          ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xE63A251F),
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 3),
                          boxShadow: [BoxShadow(color: color, blurRadius: 18)],
                        ),
                        child: SizedBox.square(
                          dimension: reducedMotion ? 54 : 54 + (8 * progress),
                          child: Icon(icon, color: color, size: 32),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
