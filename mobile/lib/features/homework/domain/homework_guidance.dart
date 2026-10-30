class HomeworkGuidance {
  const HomeworkGuidance({
    required this.steps,
    required this.finalHint,
    this.workedSteps = const <WorkedStep>[],
    this.finalAnswer,
  });

  factory HomeworkGuidance.fromJson(Map<String, Object?> json) => HomeworkGuidance(
        steps: (json['steps']! as List).cast<String>(),
        finalHint: json['finalHint']! as String,
        workedSteps: ((json['workedSteps'] as List?) ?? const <Object?>[])
            .map((Object? step) => WorkedStep.fromJson((step! as Map).cast<String, Object?>()))
            .toList(),
        finalAnswer: json['finalAnswer'] as String?,
      );

  /// Plain-text steps — always present; what's shown when there's no worked solution (offline).
  final List<String> steps;
  final String finalHint;

  /// A real worked solution (explanation + math per step) when the AI solved the question.
  final List<WorkedStep> workedSteps;
  final String? finalAnswer;

  bool get isWorkedSolution => workedSteps.isNotEmpty && finalAnswer != null;
}

class WorkedStep {
  const WorkedStep({required this.explanation, this.work});

  factory WorkedStep.fromJson(Map<String, Object?> json) =>
      WorkedStep(explanation: json['explanation']! as String, work: json['work'] as String?);

  final String explanation;

  /// The math for this step and its result, e.g. "C = 12 + 3 x 5 = 27". Null if the step has none.
  final String? work;
}
