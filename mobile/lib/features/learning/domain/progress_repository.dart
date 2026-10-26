import 'progress.dart';

/// Read-only: a lesson's score/completion is derived server-side from exercise attempts (see
/// `ExerciseRepository.submitAnswer`), never submitted directly by the client.
abstract interface class ProgressRepository {
  Future<List<LessonProgress>> progress(String token, String childId);
}
