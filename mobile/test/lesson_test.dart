import 'package:flutter_test/flutter_test.dart';
import 'package:novalearn_mobile/features/learning/domain/exercise_evaluation.dart';
import 'package:novalearn_mobile/features/learning/domain/lesson.dart';

void main() {
  group('Lesson', () {
    test('parses a lesson with its exercises from JSON, with no answer index', () {
      final Lesson lesson = Lesson.fromJson(<String, Object?>{
        'code': 'G1-ADD-01',
        'subject': 'MATH',
        'title': 'Adding within 10',
        'description': 'Use pictures and counting to add two small numbers.',
        'exercises': <Map<String, Object?>>[
          <String, Object?>{
            'id': 'exercise-1',
            'order': 1,
            'prompt': 'What is 2 + 2?',
            'choices': <String>['3', '4', '5'],
          },
        ],
      });

      expect(lesson.code, 'G1-ADD-01');
      expect(lesson.exercises, hasLength(1));
      expect(lesson.exercises.single.prompt, 'What is 2 + 2?');
      expect(lesson.exercises.single.choices, <String>['3', '4', '5']);
    });
  });

  group('ExerciseEvaluation', () {
    test('parses a correct answer with no hint', () {
      final ExerciseEvaluation evaluation = ExerciseEvaluation.fromJson(
          <String, Object?>{'correct': true, 'explanation': '2 + 2 = 4.', 'hint': null});

      expect(evaluation.correct, isTrue);
      expect(evaluation.hint, isNull);
    });

    test('parses an incorrect answer with a hint', () {
      final ExerciseEvaluation evaluation = ExerciseEvaluation.fromJson(
          <String, Object?>{'correct': false, 'explanation': '2 + 2 = 4.', 'hint': 'Count up from 2.'});

      expect(evaluation.correct, isFalse);
      expect(evaluation.hint, 'Count up from 2.');
    });
  });
}
