import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novalearn_mobile/core/widgets/parent_gate.dart';

Future<bool?> _open(WidgetTester tester, {required bool solve}) async {
  bool? result;
  await tester.pumpWidget(MaterialApp(
      home: Builder(
          builder: (BuildContext context) => FilledButton(
              onPressed: () async => result = await showParentGate(context),
              child: const Text('Open')))));
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  if (find.text('Just for grown-ups').evaluate().isNotEmpty) {
    if (!solve) return null;
    final String sum = (tester.widget(find.textContaining(' = ?')) as Text).data!;
    final List<int> parts = RegExp(r'\d+').allMatches(sum).map((m) => int.parse(m.group(0)!)).toList();
    await tester.enterText(find.byType(TextField), '${parts[0] + parts[1]}');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }
  return result;
}

void main() {
  DateTime now = DateTime(2026, 11, 2, 9);
  setUp(() {
    lockParentGate();
    now = DateTime(2026, 11, 2, 9);
    parentGateClock = () => now;
  });
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

  testWidgets('a solved gate stays open for a few minutes, then asks again', (WidgetTester tester) async {
    expect(await _open(tester, solve: true), isTrue);

    now = now.add(const Duration(minutes: 5));
    expect(await _open(tester, solve: false), isTrue, reason: 'still unlocked, no dialog shown');

    now = now.add(parentGateUnlockDuration);
    expect(await _open(tester, solve: false), isNull, reason: 'expired, the challenge is back');
    expect(find.text('Just for grown-ups'), findsOneWidget);
  });

  testWidgets('locking (on sign-out) requires the challenge again', (WidgetTester tester) async {
    expect(await _open(tester, solve: true), isTrue);
    lockParentGate();
    expect(await _open(tester, solve: false), isNull);
    expect(find.text('Just for grown-ups'), findsOneWidget);
  });
}
