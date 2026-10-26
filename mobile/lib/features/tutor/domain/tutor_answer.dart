class TutorAnswer {
  const TutorAnswer({required this.strategy, required this.explanation});

  factory TutorAnswer.fromJson(Map<String, Object?> json) => TutorAnswer(
        strategy: json['strategy']! as String,
        explanation: json['explanation']! as String,
      );

  final String strategy;
  final String explanation;
}
