import 'package:flutter_test/flutter_test.dart';
import 'package:novalearn_mobile/features/learning/domain/lesson.dart';

void main() {
  group('LessonAttempt', () {
    test('is incomplete until every question has an answer', () {
      final LessonAttempt attempt = LessonAttempt(gradeOneAdditionLesson);
      attempt.answer(0, 1);
      expect(attempt.isComplete, isFalse);
    });

    test('calculates a percentage score from correct answers', () {
      final LessonAttempt attempt = LessonAttempt(gradeOneAdditionLesson);
      attempt.answer(0, 1);
      attempt.answer(1, 2);
      attempt.answer(2, 0);
      expect(attempt.correctAnswers, 2);
      expect(attempt.score, 67);
    });
  });
}
