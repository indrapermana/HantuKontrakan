import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/features/home/game_feedback_overlay.dart';
import 'package:hantu_kontrakan/services/game_feedback_service.dart';

void main() {
  testWidgets('normal feedback animates particles and then fades', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GameFeedbackOverlay(
          signal: GameFeedbackSignal(sequence: 1, kind: GameFeedbackKind.coin),
          reducedMotion: false,
        ),
      ),
    );
    expect(find.byType(DecoratedBox), findsNWidgets(9));
    await tester.pump(const Duration(milliseconds: 900));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);
  });

  testWidgets('reduced motion removes flying particles', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GameFeedbackOverlay(
          signal: GameFeedbackSignal(
            sequence: 2,
            kind: GameFeedbackKind.reward,
          ),
          reducedMotion: true,
        ),
      ),
    );
    expect(find.byType(DecoratedBox), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);
  });
}
