import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novalearn_mobile/core/widgets/parent_gate.dart';

void main() {
  testWidgets('rejects a wrong answer and keeps the dialog open', (WidgetTester tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (BuildContext context) => FilledButton(
                onPressed: () async => result = await showParentGate(context),
                child: const Text('Open')))));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Just for grown-ups'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '1');
    await tester.tap(find.text('Continue'));
    await tester.pump();

    // Still showing — a wrong answer never closes the dialog, and the future hasn't resolved yet.
    expect(find.text('Just for grown-ups'), findsOneWidget);
    expect(result, isNull);
    expect(find.text('Not quite — try again.'), findsOneWidget);
  });

  testWidgets('cancel resolves false without requiring an answer', (WidgetTester tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (BuildContext context) => FilledButton(
                onPressed: () async => result = await showParentGate(context),
                child: const Text('Open')))));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}
