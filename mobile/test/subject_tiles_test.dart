import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novalearn_mobile/features/children/domain/child.dart';
import 'package:novalearn_mobile/features/learning/domain/child_dashboard.dart';
import 'package:novalearn_mobile/features/learning/domain/dashboard_repository.dart';
import 'package:novalearn_mobile/features/learning/domain/exercise_evaluation.dart';
import 'package:novalearn_mobile/features/learning/domain/exercise_repository.dart';
import 'package:novalearn_mobile/features/learning/domain/lesson.dart';
import 'package:novalearn_mobile/features/learning/domain/lessons_repository.dart';
import 'package:novalearn_mobile/features/learning/presentation/lesson_list_screen.dart';

LessonSummary _summary(String code, String subject, String title) =>
    LessonSummary(code: code, subject: subject, gradeLevel: 'GRADE_4', title: title, description: '...');

class _FakeLessons implements LessonsRepository {
  _FakeLessons(this.summaries);
  final List<LessonSummary> summaries;

  @override
  Future<List<LessonSummary>> lessons(String token, String childId) async => summaries;

  @override
  Future<Lesson> lesson(String token, String code) => throw UnimplementedError();

  @override
  Future<Lesson> lessonSet(String token, String childId, String code, {int? number}) =>
      throw UnimplementedError();
}

class _FakeDashboard implements DashboardRepository {
  @override
  Future<ChildDashboard> dashboard(String token, String childId) async => const ChildDashboard(
      lessonsCompletedThisWeek: 0,
      totalLessonsAttempted: 0,
      averageScore: 0,
      strongestSubject: null,
      weakestSubject: null,
      coins: 0,
      currentStreak: 0,
      longestStreak: 0);
}

class _FakeExercises implements ExerciseRepository {
  @override
  Future<ExerciseEvaluation> submitAnswer(String token, String childId, String exerciseId, int index) =>
      throw UnimplementedError();
}

final Child _child = Child(
    id: 'child-1', displayName: 'Aadhya', birthDate: DateTime(2016), gradeLevel: 'GRADE_4', avatar: 'FOX');

Future<void> _pump(WidgetTester tester, List<LessonSummary> summaries) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: LessonListTab(
              token: 't',
              child: _child,
              lessonsRepository: _FakeLessons(summaries),
              exerciseRepository: _FakeExercises(),
              dashboardRepository: _FakeDashboard(),
              onLessonCompleted: () {}))));
  await tester.pumpAndSettle();
}

void main() {
  final List<LessonSummary> fiveSubjects = <LessonSummary>[
    _summary('G4-RATIO-01', 'MATH', 'Ratios and Rates'),
    _summary('G4-PCT-01', 'MATH', 'Percentages'),
    _summary('G4-ENG-01', 'ENGLISH', 'Prefixes'),
    _summary('G4-EVS-CROPS-01', 'EVS', 'From Field to Plate'),
    _summary('G4-HIN-KAAL-01', 'HINDI', 'Tenses (काल)'),
    _summary('G4-TEL-KAALALU-01', 'TELUGU', 'Tenses (కాలాలు)'),
  ];

  testWidgets('the Learn tab opens on subject tiles, not a list of every lesson', (WidgetTester tester) async {
    await _pump(tester, fiveSubjects);

    expect(find.text('Pick a subject'), findsOneWidget);
    for (final String name in <String>['Math', 'English', 'EVS', 'Hindi', 'Telugu']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('2 lessons'), findsOneWidget); // Math
    expect(find.text('1 lesson'), findsNWidgets(4));
    expect(find.text('Ratios and Rates'), findsNothing);
  });

  testWidgets('tapping a subject shows only its lessons, and "All subjects" goes back', (WidgetTester tester) async {
    await _pump(tester, fiveSubjects);

    await tester.tap(find.text('Math'));
    await tester.pumpAndSettle();
    expect(find.text('Ratios and Rates'), findsOneWidget);
    expect(find.text('Percentages'), findsOneWidget);
    expect(find.text('Tenses (కాలాలు)'), findsNothing);

    await tester.tap(find.text('All subjects'));
    await tester.pumpAndSettle();
    expect(find.text('Pick a subject'), findsOneWidget);

    await tester.tap(find.text('Telugu'));
    await tester.pumpAndSettle();
    expect(find.text('Tenses (కాలాలు)'), findsOneWidget);
    expect(find.text('Ratios and Rates'), findsNothing);
  });

  testWidgets('a grade with only one subject skips the tiles', (WidgetTester tester) async {
    await _pump(tester, <LessonSummary>[_summary('G1-ADD-01', 'MATH', 'Adding within 10')]);

    expect(find.text('Pick a subject'), findsNothing);
    expect(find.text('All subjects'), findsNothing);
    expect(find.text('Adding within 10'), findsOneWidget);
  });
}
