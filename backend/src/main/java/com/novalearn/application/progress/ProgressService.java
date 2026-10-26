package com.novalearn.application.progress;

import com.novalearn.application.catalog.ExerciseRepository;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.application.rewards.RewardsService;
import com.novalearn.domain.catalog.Exercise;
import com.novalearn.domain.progress.LessonProgress;
import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Lesson-level progress is now derived from individual exercise attempts (see
 * {@link ExerciseEvaluationService}), not submitted directly by the client — a lesson is complete
 * once every one of its exercises has been attempted, and its score is the percentage answered
 * correctly. There is deliberately no public "set my score to X" method any more: a prior version
 * of this API let the client submit {@code completed=true, score=100} outright, which this
 * redesign closes.
 */
@Service
public class ProgressService {

  private static final int COINS_PER_COMPLETED_LESSON = 10;
  private static final int BONUS_COINS_FOR_PERFECT_SCORE = 5;
  private static final String LESSON_COMPLETION_REASON = "Completed a lesson";
  private static final String LESSON_COMPLETION_REFERENCE_TYPE = "LESSON_COMPLETION";

  private final LessonProgressRepository progress;
  private final ChildProfileRepository children;
  private final ExerciseRepository exercises;
  private final ExerciseAttemptRepository attempts;
  private final RewardsService rewards;

  public ProgressService(
      LessonProgressRepository progress,
      ChildProfileRepository children,
      ExerciseRepository exercises,
      ExerciseAttemptRepository attempts,
      RewardsService rewards) {
    this.progress = progress;
    this.children = children;
    this.exercises = exercises;
    this.attempts = attempts;
    this.rewards = rewards;
  }

  @Transactional(readOnly = true)
  public List<LessonProgress> list(UUID parentId, UUID childId) {
    if (!children.belongsToParent(childId, parentId)) {
      throw new ChildNotFoundException();
    }
    return progress.findByChildId(childId);
  }

  /** Recomputes one lesson's completion/score for a child from their exercise attempts, and awards coins exactly once on the transition into "completed." */
  @Transactional
  LessonProgress recalculate(UUID childId, String lessonCode) {
    Set<UUID> exerciseIds = exercises.findByLessonCode(lessonCode).stream().map(Exercise::id).collect(Collectors.toSet());
    int total = exerciseIds.size();
    int attemptedCount = attempts.findAttemptedExerciseIds(childId, exerciseIds).size();
    long correctCount = attempts.countCorrectAmong(childId, exerciseIds);
    boolean completed = total > 0 && attemptedCount == total;
    int score = total == 0 ? 0 : (int) Math.round(100.0 * correctCount / total);

    LessonProgress current = progress.findByChildIdAndLessonCode(childId, lessonCode)
        .orElse(new LessonProgress(UUID.randomUUID(), childId, lessonCode, 0, false, Instant.now()));
    boolean newlyCompleted = completed && !current.completed();
    LessonProgress saved = progress.save(new LessonProgress(current.id(), childId, lessonCode, score, completed, Instant.now()));

    if (newlyCompleted) {
      int coins = COINS_PER_COMPLETED_LESSON + (score == 100 ? BONUS_COINS_FOR_PERFECT_SCORE : 0);
      rewards.award(childId, coins, LESSON_COMPLETION_REASON, LESSON_COMPLETION_REFERENCE_TYPE, saved.id().toString());
    }
    return saved;
  }
}
