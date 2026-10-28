class ExerciseEvaluation {
  const ExerciseEvaluation(
      {required this.correct, required this.explanation, this.hint, this.correctChoiceText});

  factory ExerciseEvaluation.fromJson(Map<String, Object?> json) => ExerciseEvaluation(
        correct: json['correct']! as bool,
        explanation: json['explanation']! as String,
        hint: json['hint'] as String?,
        correctChoiceText: json['correctChoiceText'] as String?,
      );

  final bool correct;
  final String explanation;
  final String? hint;

  /// The correct choice's own text (e.g. `"FRACTION:1:2:1/2"`), sent only after grading — lets
  /// the feedback card draw the same picture for the right answer that the choice list already
  /// draws, instead of a text-only explanation.
  final String? correctChoiceText;
}
