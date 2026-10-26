package com.novalearn.application.rewards;

import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.rewards.ChildRewards;
import java.time.Clock;
import java.time.LocalDate;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Coins and streaks, recalculated whenever a lesson is completed for the first time.
 * {@link com.novalearn.application.progress.ProgressService} is the only caller of
 * {@link #recordLessonCompletion}, and only on the transition into "completed" — re-finishing an
 * already-completed lesson never re-awards coins.
 */
@Service
public class RewardsService {

  private static final int COINS_PER_COMPLETED_LESSON = 10;
  private static final int BONUS_COINS_FOR_PERFECT_SCORE = 5;

  private final ChildRewardsRepository rewards;
  private final ChildProfileRepository children;
  private final Clock clock;

  public RewardsService(ChildRewardsRepository rewards, ChildProfileRepository children, Clock clock) {
    this.rewards = rewards;
    this.children = children;
    this.clock = clock;
  }

  @Transactional
  public ChildRewards recordLessonCompletion(UUID childId, int score) {
    ChildRewards current = rewards.findByChildId(childId).orElse(ChildRewards.initial(childId));
    int earned = COINS_PER_COMPLETED_LESSON + (score == 100 ? BONUS_COINS_FOR_PERFECT_SCORE : 0);
    LocalDate today = LocalDate.now(clock);
    int currentStreak = nextStreak(current, today);
    int longestStreak = Math.max(current.longestStreak(), currentStreak);
    return rewards.save(new ChildRewards(childId, current.coins() + earned, currentStreak, longestStreak, today));
  }

  @Transactional(readOnly = true)
  public ChildRewards get(UUID parentId, UUID childId) {
    if (!children.belongsToParent(childId, parentId)) {
      throw new ChildNotFoundException();
    }
    return rewards.findByChildId(childId).orElse(ChildRewards.initial(childId));
  }

  private int nextStreak(ChildRewards current, LocalDate today) {
    LocalDate lastActivity = current.lastActivityDate();
    if (lastActivity == null || lastActivity.isBefore(today.minusDays(1))) {
      return 1;
    }
    if (lastActivity.isEqual(today)) {
      return Math.max(current.currentStreak(), 1);
    }
    return current.currentStreak() + 1;
  }
}
