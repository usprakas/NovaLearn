class LessonSummary {
  const LessonSummary({
    required this.code,
    required this.subject,
    required this.gradeLevel,
    required this.title,
    required this.description,
  });

  factory LessonSummary.fromJson(Map<String, Object?> json) => LessonSummary(
        code: json['code']! as String,
        subject: json['subject']! as String,
        gradeLevel: json['gradeLevel']! as String,
        title: json['title']! as String,
        description: json['description']! as String,
      );

  final String code;
  final String subject;
  final String gradeLevel;
  final String title;
  final String description;
}

class Lesson {
  const Lesson({
    required this.code,
    required this.subject,
    required this.title,
    required this.description,
    required this.exercises,
  });

  factory Lesson.fromJson(Map<String, Object?> json) => Lesson(
        code: json['code']! as String,
        subject: json['subject']! as String,
        title: json['title']! as String,
        description: json['description']! as String,
        exercises: (json['exercises']! as List)
            .cast<Map<String, Object?>>()
            .map(Exercise.fromJson)
            .toList(),
      );

  final String code;
  final String subject;
  final String title;
  final String description;
  final List<Exercise> exercises;
}

/// Deliberately carries no answer-index field: scoring is server-side now (see
/// `POST /children/{childId}/exercises/{exerciseId}/attempts`), so the mobile client never has
/// the correct answer to begin with.
class Exercise {
  const Exercise({
    required this.id,
    required this.order,
    required this.prompt,
    required this.choices,
  });

  factory Exercise.fromJson(Map<String, Object?> json) => Exercise(
        id: json['id']! as String,
        order: json['order']! as int,
        prompt: json['prompt']! as String,
        choices: (json['choices']! as List).cast<String>(),
      );

  final String id;
  final int order;
  final String prompt;
  final List<String> choices;
}
