class HomeworkGuidance {
  const HomeworkGuidance({required this.steps, required this.finalHint});

  factory HomeworkGuidance.fromJson(Map<String, Object?> json) => HomeworkGuidance(
        steps: (json['steps']! as List).cast<String>(),
        finalHint: json['finalHint']! as String,
      );

  final List<String> steps;
  final String finalHint;
}
