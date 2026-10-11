import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/app/app.dart';
import 'package:hantu_kontrakan/services/save_service.dart';

void main() {
  testWidgets('complaint resolution visibly updates and persists state', (
    tester,
  ) async {
    final saves = MemorySaveService();
    await tester.pumpWidget(HantuKontrakanApp(saveService: saves));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('200 Koin Arwah'), findsOneWidget);
    expect(find.text('Pocong 35'), findsOneWidget);

    await tester.tap(find.byKey(const Key('complaint-button')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const Key('choice-soundproof')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('150 Koin Arwah'), findsOneWidget);
    expect(find.text('Pocong 55'), findsOneWidget);
    expect(find.text('Keluhan selesai dan tersimpan'), findsOneWidget);
    expect(saves.storedState?.complaintResolved, isTrue);
  });
}
