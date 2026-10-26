class LessonProgress {
  const LessonProgress({
    required this.id,
    required this.lessonCode,
    required this.score,
    required this.completed,
  });

  factory LessonProgress.fromJson(Map<String, Object?> json) => LessonProgress(
        id: json['id']! as String,
        lessonCode: json['lessonCode']! as String,
        score: json['score']! as int,
        completed: json['completed']! as bool,
      );
  final String id;
  final String lessonCode;
  final int score;
  final bool completed;
}

class LessonProgressDraft {
  const LessonProgressDraft({
    required this.lessonCode,
    required this.score,
    required this.completed,
  });
  final String lessonCode;
  final int score;
  final bool completed;
  Map<String, Object> toJson() => <String, Object>{
        'score': score,
        'completed': completed,
      };
}
