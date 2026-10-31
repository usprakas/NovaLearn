import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:novalearn_mobile/core/network/novalearn_api.dart';
import 'package:novalearn_mobile/features/children/domain/child.dart';
import 'package:novalearn_mobile/features/learning/domain/exercise_evaluation.dart';
import 'package:novalearn_mobile/features/learning/domain/exercise_repository.dart';
import 'package:novalearn_mobile/features/learning/domain/lesson.dart';
import 'package:novalearn_mobile/features/learning/domain/lessons_repository.dart';
import 'package:novalearn_mobile/features/learning/presentation/lesson_screen.dart';

Lesson _set(int number, int total, {bool completedAll = false}) => Lesson(
      code: 'G1-ADD-01',
      subject: 'MATH',
      title: 'Adding within 10',
      description: '...',
      setNumber: number,
      totalSets: total,
      completedAllSets: completedAll,
      exercises: <Exercise>[
        Exercise(id: 'q$number', order: number, prompt: 'Question from set $number', choices: const <String>['1', '2', '3']),
      ],
    );

class _FakeLessons implements LessonsRepository {
  final List<int?> requested = <int?>[];

  @override
  Future<Lesson> lessonSet(String token, String childId, String code, {int? number}) async {
    requested.add(number);
    return _set(number ?? 1, 2, completedAll: number == 1);
  }

  @override
  Future<List<LessonSummary>> lessons(String token, String childId) async => <LessonSummary>[];

  @override
  Future<Lesson> lesson(String token, String code) async => _set(1, 1);
}

class _FakeExercises implements ExerciseRepository {
  @override
  Future<ExerciseEvaluation> submitAnswer(String token, String childId, String exerciseId, int index) async =>
      const ExerciseEvaluation(correct: true, explanation: 'Well done.');
}

final Child _child = Child(
    id: 'child-1', displayName: 'Anshu', birthDate: DateTime(2019), gradeLevel: 'GRADE_1', avatar: 'FOX');

void _tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _answerAndFinish(WidgetTester tester) async {
  await tester.tap(find.text('2'));
  await tester.pump();
  await tester.tap(find.text('Submit answer'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Finish set'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('finishing a set offers the next one, then practice once every set is done', (WidgetTester tester) async {
    _tallView(tester);
    final _FakeLessons lessons = _FakeLessons();
    await tester.pumpWidget(MaterialApp(
        home: LessonScreen(
            token: 't', child: _child, lesson: _set(1, 2), exerciseRepository: _FakeExercises(), lessonsRepository: lessons)));

    expect(find.text('Set 1 of 2'), findsOneWidget);
    await _answerAndFinish(tester);

    expect(find.text('Set 1 done!'), findsOneWidget);
    await tester.tap(find.text('Start set 2'));
    await tester.pumpAndSettle();

    expect(lessons.requested, <int?>[2]);
    expect(find.text('Set 2 of 2'), findsOneWidget);
    expect(find.text('Question from set 2'), findsOneWidget);
    await _answerAndFinish(tester);

    expect(find.text('You finished every set!'), findsOneWidget);
    expect(find.text('Start set 3'), findsNothing);
    await tester.tap(find.text('Practice again'));
    await tester.pumpAndSettle();

    expect(lessons.requested, <int?>[2, 1]);
    expect(find.text('Practice round · Set 1 of 2'), findsOneWidget);
  });

  testWidgets('a single-set lesson finishes with a lesson-complete panel and no next set', (WidgetTester tester) async {
    _tallView(tester);
    await tester.pumpWidget(MaterialApp(
        home: LessonScreen(
            token: 't', child: _child, lesson: _set(1, 1), exerciseRepository: _FakeExercises(), lessonsRepository: _FakeLessons())));

    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('Submit answer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish lesson'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson complete!'), findsOneWidget);
    expect(find.text('Practice again'), findsNothing);
    expect(find.text('Back to lessons'), findsOneWidget);
  });

  test('parses set fields, and a plain lesson reads as one set', () {
    final Map<String, Object?> json = <String, Object?>{
      'code': 'L', 'subject': 'MATH', 'title': 'T', 'description': 'D', 'exercises': <Object>[],
    };
    final Lesson plain = Lesson.fromJson(json);
    expect(plain.setNumber, 1);
    expect(plain.totalSets, 1);
    expect(plain.hasNextSet, isFalse);

    final Lesson set = Lesson.fromJson(<String, Object?>{...json, 'setNumber': 1, 'totalSets': 3, 'completedAllSets': false});
    expect(set.hasNextSet, isTrue);
  });

  test('requests the next unfinished set, or a numbered one', () async {
    final List<Uri> seen = <Uri>[];
    final MockClient client = MockClient((http.Request request) async {
      seen.add(request.url);
      expect(request.headers['Authorization'], 'Bearer t');
      return http.Response(
          jsonEncode(<String, Object?>{
            'code': 'G1-ADD-01', 'subject': 'MATH', 'title': 'T', 'description': 'D',
            'setNumber': 2, 'totalSets': 2, 'completedAllSets': false, 'exercises': <Object>[],
          }),
          200);
    });
    final NovaLearnApi api = NovaLearnApi(client: client, baseUrl: 'https://api.example.test');

    await api.lessonSet('t', 'c1', 'G1-ADD-01');
    final Lesson numbered = await api.lessonSet('t', 'c1', 'G1-ADD-01', number: 2);

    expect(seen[0].path, '/api/v1/children/c1/lessons/G1-ADD-01/set');
    expect(seen[0].queryParameters, isEmpty);
    expect(seen[1].queryParameters, <String, String>{'number': '2'});
    expect(numbered.setNumber, 2);
  });
}
