package com.novalearn.application.dashboard;

import com.novalearn.application.catalog.LessonCatalogService;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.application.progress.LessonProgressRepository;
import com.novalearn.application.rewards.RewardsService;
import com.novalearn.domain.dashboard.ChildDashboard;
import com.novalearn.domain.progress.LessonProgress;
import com.novalearn.domain.rewards.ChildRewardsSummary;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Combines progress, rewards, and the lesson catalog's subject tags into one parent-facing summary. */
@Service
public class DashboardService {

  private final ChildProfileRepository children;
  private final LessonProgressRepository progress;
  private final RewardsService rewards;
  private final LessonCatalogService catalog;

  public DashboardService(
      ChildProfileRepository children, LessonProgressRepository progress, RewardsService rewards, LessonCatalogService catalog) {
    this.children = children;
    this.progress = progress;
    this.rewards = rewards;
    this.catalog = catalog;
  }

  @Transactional(readOnly = true)
  public ChildDashboard get(UUID parentId, UUID childId) {
    if (!children.belongsToParent(childId, parentId)) {
      throw new ChildNotFoundException();
    }
    List<LessonProgress> attempts = progress.findByChildId(childId);
    Instant weekAgo = Instant.now().minus(Duration.ofDays(7));
    long completedThisWeek = attempts.stream().filter(p -> p.completed() && p.updatedAt().isAfter(weekAgo)).count();
    int averageScore = (int) Math.round(attempts.stream().mapToInt(LessonProgress::score).average().orElse(0));

    Map<String, List<Integer>> scoresBySubject = new LinkedHashMap<>();
    for (LessonProgress attempt : attempts) {
      String subject = catalog.subjectOf(attempt.lessonCode()).orElse("OTHER");
      scoresBySubject.computeIfAbsent(subject, ignored -> new ArrayList<>()).add(attempt.score());
    }
    String strongestSubject = null;
    String weakestSubject = null;
    double best = -1;
    double worst = Double.MAX_VALUE;
    for (Map.Entry<String, List<Integer>> entry : scoresBySubject.entrySet()) {
      double average = entry.getValue().stream().mapToInt(Integer::intValue).average().orElse(0);
      if (average > best) {
        best = average;
        strongestSubject = entry.getKey();
      }
      if (average < worst) {
        worst = average;
        weakestSubject = entry.getKey();
      }
    }

    ChildRewardsSummary childRewards = rewards.get(parentId, childId);
    return new ChildDashboard((int) completedThisWeek, attempts.size(), averageScore, strongestSubject, weakestSubject,
        childRewards.coins(), childRewards.currentStreak(), childRewards.longestStreak());
  }
}
