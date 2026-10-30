import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novalearn_mobile/features/children/domain/child.dart';
import 'package:novalearn_mobile/features/homework/domain/homework_guidance.dart';
import 'package:novalearn_mobile/features/homework/domain/homework_repository.dart';
import 'package:novalearn_mobile/features/homework/presentation/homework_screen.dart';

class _Repo implements HomeworkRepository {
  _Repo(this.guidance);
  final HomeworkGuidance guidance;

  @override
  Future<HomeworkGuidance> explain(String token, String childId, String questionText) async => guidance;

  @override
  Future<String> scanQuestion(String token, String childId, Uint8List imageBytes) async => '';
}

Future<void> _ask(WidgetTester tester, HomeworkGuidance guidance) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: HomeworkTab(
              token: 't',
              child: Child(
                  id: 'c', displayName: 'Ava', birthDate: DateTime(2016, 1, 1), gradeLevel: 'GRADE_5', avatar: 'FOX'),
              homeworkRepository: _Repo(guidance)))));
  await tester.enterText(find.byType(TextField), 'Streaming costs \$12 plus \$3 per movie. Cost of 5 movies?');
  await tester.pump();
  await tester.tap(find.text('Help me understand'));
  await tester.pumpAndSettle();
}

void main() {
  test('parses a worked solution, and an offline response without one', () {
    final HomeworkGuidance worked = HomeworkGuidance.fromJson(<String, Object?>{
      'steps': <String>['a'],
      'finalHint': 'Answer: 27. Nice!',
      'workedSteps': <Object?>[
        <String, Object?>{'explanation': 'Multiply.', 'work': '3 x 5 = 15'},
        <String, Object?>{'explanation': 'Think about it.'},
      ],
      'finalAnswer': '27',
    });
    expect(worked.isWorkedSolution, isTrue);
    expect(worked.workedSteps[0].work, '3 x 5 = 15');
    expect(worked.workedSteps[1].work, isNull);

    final HomeworkGuidance offline =
        HomeworkGuidance.fromJson(<String, Object?>{'steps': <String>['Read it slowly.'], 'finalHint': 'You can do it'});
    expect(offline.isWorkedSolution, isFalse);
  });

  testWidgets('shows each step with its math and the final answer', (WidgetTester tester) async {
    await _ask(
        tester,
        const HomeworkGuidance(
          steps: <String>['unused'],
          finalHint: 'Answer: \$27. You turned words into math!',
          workedSteps: <WorkedStep>[
            WorkedStep(explanation: 'Each movie costs \$3, so m movies cost 3 x m.', work: 'C = 12 + 3m'),
            WorkedStep(explanation: 'Put in 5 for m.', work: 'C = 12 + 3 x 5 = 27'),
          ],
          finalAnswer: '\$27',
        ));

    expect(find.text("Let's solve it together"), findsOneWidget);
    expect(find.text('C = 12 + 3m'), findsOneWidget);
    expect(find.text('C = 12 + 3 x 5 = 27'), findsOneWidget);
    expect(find.text('\$27'), findsOneWidget);
    // The tip is shown on its own, without repeating the answer prefix.
    expect(find.text('You turned words into math!'), findsOneWidget);
    expect(find.text('unused'), findsNothing);
  });

  testWidgets('falls back to plain steps when there is no worked solution', (WidgetTester tester) async {
    await _ask(tester, const HomeworkGuidance(steps: <String>['Read the question slowly.'], finalHint: 'Keep going!'));

    expect(find.text('Read the question slowly.'), findsOneWidget);
    expect(find.text('Answer'), findsNothing);
  });
}
