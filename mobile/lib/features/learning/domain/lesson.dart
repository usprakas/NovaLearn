class LessonSummary {
  const LessonSummary({
    required this.code,
    required this.subject,
    required this.title,
    required this.description,
  });

  factory LessonSummary.fromJson(Map<String, Object?> json) => LessonSummary(
        code: json['code']! as String,
        subject: json['subject']! as String,
        title: json['title']! as String,
        description: json['description']! as String,
      );

  final String code;
  final String subject;
  final String title;
  final String description;
}

class Lesson {
  const Lesson({
    required this.code,
    required this.subject,
    required this.title,
    required this.description,
    required this.questions,
  });

  factory Lesson.fromJson(Map<String, Object?> json) => Lesson(
        code: json['code']! as String,
        subject: json['subject']! as String,
        title: json['title']! as String,
        description: json['description']! as String,
        questions: (json['questions']! as List)
            .cast<Map<String, Object?>>()
            .map(LessonQuestion.fromJson)
            .toList(),
      );

  final String code;
  final String subject;
  final String title;
  final String description;
  final List<LessonQuestion> questions;
}

class LessonQuestion {
  const LessonQuestion({
    required this.prompt,
    required this.choices,
    required this.answerIndex,
  });

  factory LessonQuestion.fromJson(Map<String, Object?> json) => LessonQuestion(
        prompt: json['prompt']! as String,
        choices: (json['choices']! as List).cast<String>(),
        answerIndex: json['answerIndex']! as int,
      );

  final String prompt;
  final List<String> choices;
  final int answerIndex;
}

/// A fixed offline lesson kept only as a fixture for widget/unit tests that do not hit the
/// network; the running app always fetches lessons from `GET /api/v1/lessons/{code}`.
const Lesson gradeOneAdditionLesson = Lesson(
  code: 'G1-ADD-01',
  subject: 'MATH',
  title: 'Adding within 10',
  description: 'Use pictures and counting to add two small numbers.',
  questions: <LessonQuestion>[
    LessonQuestion(
      prompt:
          'Maya has 2 apples. Her friend gives her 3 more. How many apples does Maya have?',
      choices: <String>['4', '5', '6'],
      answerIndex: 1,
    ),
    LessonQuestion(
      prompt: 'What is 4 + 1?',
      choices: <String>['3', '4', '5'],
      answerIndex: 2,
    ),
    LessonQuestion(
      prompt: 'What is 3 + 3?',
      choices: <String>['5', '6', '7'],
      answerIndex: 1,
    ),
  ],
);

class LessonAttempt {
  LessonAttempt(this.lesson)
      : _answers = List<int?>.filled(lesson.questions.length, null);
  final Lesson lesson;
  final List<int?> _answers;
  int get questionCount => lesson.questions.length;
  bool get isComplete => _answers.every((int? answer) => answer != null);
  int? answerAt(int index) => _answers[index];
  void answer(int questionIndex, int choiceIndex) =>
      _answers[questionIndex] = choiceIndex;
  int get score => ((correctAnswers / questionCount) * 100).round();
  int get correctAnswers =>
      List<int>.generate(questionCount, (int index) => index)
          .where((int index) =>
              _answers[index] == lesson.questions[index].answerIndex)
          .length;
}
