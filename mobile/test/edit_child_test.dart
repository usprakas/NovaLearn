import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novalearn_mobile/core/widgets/parent_gate.dart';
import 'package:novalearn_mobile/features/children/domain/child.dart';
import 'package:novalearn_mobile/features/children/domain/children_repository.dart';
import 'package:novalearn_mobile/features/children/presentation/child_picker.dart';

class _FakeChildren implements ChildrenRepository {
  Child kiaan = Child(id: 'c1', displayName: 'Kiaan', birthDate: DateTime(2015, 4, 2), gradeLevel: 'GRADE_6', avatar: 'FOX');
  final List<ChildDraft> updates = <ChildDraft>[];

  @override
  Future<List<Child>> children(String token) async => <Child>[kiaan];

  @override
  Future<Child> createChild(String token, ChildDraft draft) => throw UnimplementedError();

  @override
  Future<Child> updateChild(String token, String childId, ChildDraft draft) async {
    updates.add(draft);
    return kiaan = Child(
        id: childId, displayName: draft.displayName.trim(), birthDate: draft.birthDate, gradeLevel: draft.gradeLevel, avatar: draft.avatar);
  }
}

Future<void> _solveGate(WidgetTester tester) async {
  final String sum = (tester.widget(find.textContaining(' = ?')) as Text).data!;
  final List<int> parts = RegExp(r'\d+').allMatches(sum).map((RegExpMatch m) => int.parse(m.group(0)!)).toList();
  await tester.enterText(find.byType(TextField), '${parts[0] + parts[1]}');
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(lockParentGate);

  testWidgets('a parent can change a child\'s grade after the parent gate, keeping the same child', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final _FakeChildren repository = _FakeChildren();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ChildPicker(
                token: 't',
                childrenRepository: repository,
                builder: (BuildContext context, Child child, VoidCallback reload) =>
                    Text('Showing ${child.displayName} in ${gradeLevelLabel(child.gradeLevel)}')))));
    await tester.pumpAndSettle();
    expect(find.text('Showing Kiaan in Grade 6'), findsOneWidget);

    await tester.tap(find.byTooltip("Edit Kiaan's profile"));
    await tester.pumpAndSettle();
    expect(find.text('Just for grown-ups'), findsOneWidget);
    await _solveGate(tester);

    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Kiaan'), findsOneWidget);
    await tester.tap(find.text('Grade 6'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grade 5').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repository.updates.single.gradeLevel, 'GRADE_5');
    expect(repository.updates.single.birthDate, DateTime(2015, 4, 2));
    expect(find.text('Showing Kiaan in Grade 5'), findsOneWidget);
  });
}
