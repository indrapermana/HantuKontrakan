import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/app/app.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/commands/game_command.dart';
import 'package:hantu_kontrakan/simulation/game_state_controller.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';

void main() {
  testWidgets('home and settings fit compact and large phone viewports', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final size in <Size>[const Size(360, 640), const Size(430, 932)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        HantuKontrakanApp(
          saveService: MemorySaveService(
            initialResult: SaveLoaded(GameState.seeded()),
          ),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const Key('settings-button')), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'home at $size');

      await tester.tap(find.byKey(const Key('settings-button')));
      await tester.pump();
      expect(find.byKey(const Key('privacy-settings-section')), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'settings at $size');

      await tester.tap(find.text('Close'));
      await tester.pump();
    }
  });

  test('ten thousand deterministic ticks stay bounded and reload exactly', () {
    final controller = GameStateController(
      GameState.seeded().copyWith(unscriptedIncidentsEnabled: false),
    );
    final stopwatch = Stopwatch()..start();

    for (var index = 0; index < 10000; index += 1) {
      controller.dispatch(const AdvanceSimulation(seconds: 1));
    }
    stopwatch.stop();

    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
    final encoded = jsonEncode(controller.state.toJson());
    final restored = GameState.fromJson(
      jsonDecode(encoded) as Map<String, Object?>,
    );
    expect(restored.toJson(), controller.state.toJson());
    expect(restored.activeSimulationSeconds, 10000);
  });

  test(
    'repeated save reload and collection cannot duplicate economy value',
    () {
      var state = GameState.seeded().copyWith(
        unscriptedIncidentsEnabled: false,
        pendingRentMicrocoins: 9876543,
      );

      for (var cycle = 0; cycle < 100; cycle += 1) {
        state = GameState.fromJson(
          jsonDecode(jsonEncode(state.toJson())) as Map<String, Object?>,
        );
      }

      final controller = GameStateController(state);
      expect(
        controller.dispatch(const CollectAllRent(claimId: 'hk029-claim')),
        isTrue,
      );
      final walletAfterFirstClaim = controller.state.walletCoins;
      final remainderAfterFirstClaim = controller.state.pendingRentMicrocoins;

      expect(
        controller.dispatch(const CollectAllRent(claimId: 'hk029-claim')),
        isFalse,
      );
      expect(controller.state.walletCoins, walletAfterFirstClaim);
      expect(controller.state.pendingRentMicrocoins, remainderAfterFirstClaim);
      expect(walletAfterFirstClaim, 209);
      expect(remainderAfterFirstClaim, 876543);
    },
  );
}
