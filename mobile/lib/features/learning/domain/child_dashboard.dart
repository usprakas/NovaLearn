class ChildDashboard {
  const ChildDashboard({
    required this.lessonsCompletedThisWeek,
    required this.totalLessonsAttempted,
    required this.averageScore,
    required this.strongestSubject,
    required this.weakestSubject,
    required this.coins,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory ChildDashboard.fromJson(Map<String, Object?> json) => ChildDashboard(
        lessonsCompletedThisWeek: json['lessonsCompletedThisWeek']! as int,
        totalLessonsAttempted: json['totalLessonsAttempted']! as int,
        averageScore: json['averageScore']! as int,
        strongestSubject: json['strongestSubject'] as String?,
        weakestSubject: json['weakestSubject'] as String?,
        coins: json['coins']! as int,
        currentStreak: json['currentStreak']! as int,
        longestStreak: json['longestStreak']! as int,
      );

  final int lessonsCompletedThisWeek;
  final int totalLessonsAttempted;
  final int averageScore;
  final String? strongestSubject;
  final String? weakestSubject;
  final int coins;
  final int currentStreak;
  final int longestStreak;
}
