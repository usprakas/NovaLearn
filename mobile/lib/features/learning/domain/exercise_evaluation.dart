class ExerciseEvaluation {
  const ExerciseEvaluation({required this.correct, required this.explanation, this.hint});

  factory ExerciseEvaluation.fromJson(Map<String, Object?> json) => ExerciseEvaluation(
        correct: json['correct']! as bool,
        explanation: json['explanation']! as String,
        hint: json['hint'] as String?,
      );

  final bool correct;
  final String explanation;
  final String? hint;
}
