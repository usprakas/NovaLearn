import 'lesson.dart';

abstract interface class LessonsRepository {
  Future<List<LessonSummary>> lessons(String token);
  Future<Lesson> lesson(String token, String code);
}
