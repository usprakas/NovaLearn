package com.novalearn.domain.dashboard;

public record ChildDashboard(
    int lessonsCompletedThisWeek,
    int totalLessonsAttempted,
    int averageScore,
    String strongestSubject,
    String weakestSubject,
    int coins,
    int currentStreak,
    int longestStreak) { }
