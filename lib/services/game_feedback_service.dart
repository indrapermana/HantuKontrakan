import 'package:flutter/services.dart';

enum HapticCue { selection, success, warning }

abstract interface class GameFeedbackService {
  Future<void> haptic(HapticCue cue);
}

class NoopGameFeedbackService implements GameFeedbackService {
  const NoopGameFeedbackService();

  @override
  Future<void> haptic(HapticCue cue) async {}
}

class FlutterGameFeedbackService implements GameFeedbackService {
  const FlutterGameFeedbackService();

  @override
  Future<void> haptic(HapticCue cue) => switch (cue) {
    HapticCue.selection => HapticFeedback.selectionClick(),
    HapticCue.success => HapticFeedback.lightImpact(),
    HapticCue.warning => HapticFeedback.mediumImpact(),
  };
}

enum GameFeedbackKind { coin, upgrade, unlock, reward, warning, tenant }

class GameFeedbackSignal {
  const GameFeedbackSignal({required this.sequence, required this.kind});

  final int sequence;
  final GameFeedbackKind kind;
}
