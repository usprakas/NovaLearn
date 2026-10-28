import 'lesson.dart';

abstract interface class LessonsRepository {
  /// Returns only the lessons at the child's own grade level — filtered server-side, not by the
  /// client, since that's where the child's actual grade is authoritatively known.
  Future<List<LessonSummary>> lessons(String token, String childId);
  Future<Lesson> lesson(String token, String code);
}
