import 'progress.dart';

abstract interface class ProgressRepository {
  Future<List<LessonProgress>> progress(String token, String childId);
  Future<LessonProgress> recordProgress(
    String token,
    String childId,
    LessonProgressDraft draft,
  );
}
