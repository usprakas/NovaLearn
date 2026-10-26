import 'exercise_evaluation.dart';

abstract interface class ExerciseRepository {
  Future<ExerciseEvaluation> submitAnswer(
    String token,
    String childId,
    String exerciseId,
    int submittedAnswerIndex,
  );
}
