import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/widgets/game_panel.dart';

void main() {
  testWidgets('game panel fits compact viewport with keyboard and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            viewInsets: EdgeInsets.only(bottom: 220),
            textScaler: TextScaler.linear(1.5),
          ),
          child: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => GameDialog(
                    title: 'Pengaturan kontrakan yang cukup panjang',
                    icon: Icons.home_work_rounded,
                    primaryAction: const GamePrimaryButton(
                      label: 'Lanjutkan',
                      onPressed: null,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: const [
                        Text(
                          'Panel tetap dapat digulir saat keyboard terlihat.',
                        ),
                        SizedBox(height: 500),
                      ],
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Lanjutkan'), findsOneWidget);
  });

  testWidgets('primary action ignores duplicate taps while awaiting', (
    tester,
  ) async {
    final completion = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GamePrimaryButton(
            label: 'Claim',
            onPressed: () {
              calls += 1;
              return completion.future;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Claim'));
    await tester.tap(find.text('Claim'));
    expect(calls, 1);

    completion.complete();
    await tester.pump();
  });
}
