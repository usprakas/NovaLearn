class TutorAnswer {
  const TutorAnswer({
    required this.strategy,
    required this.explanation,
    this.suggestedNextActivity,
    this.refused = false,
  });

  factory TutorAnswer.fromJson(Map<String, Object?> json) => TutorAnswer(
        strategy: json['strategy']! as String,
        explanation: json['explanation']! as String,
        suggestedNextActivity: json['suggestedNextActivity'] as String?,
        refused: json['refused'] as bool? ?? false,
      );

  final String strategy;
  final String explanation;
  final String? suggestedNextActivity;
  final bool refused;
}
