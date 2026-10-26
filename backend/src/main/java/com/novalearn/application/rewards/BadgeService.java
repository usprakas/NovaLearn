package com.novalearn.application.rewards;

import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.application.progress.LessonProgressRepository;
import com.novalearn.domain.progress.LessonProgress;
import com.novalearn.domain.rewards.Badge;
import com.novalearn.domain.rewards.ChildBadge;
import com.novalearn.domain.rewards.ChildStreak;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * A small, fixed set of badges with simple, readable criteria — deliberately not a generic rules
 * engine. {@code FIRST_STEPS} and {@code FIVE_DAY_STREAK} are seeded in V7's data migration;
 * {@link #evaluateAndAward} is a no-op for a badge code that isn't found there.
 */
@Service
public class BadgeService {

  public static final String FIRST_STEPS = "FIRST_STEPS";
  public static final String FIVE_DAY_STREAK = "FIVE_DAY_STREAK";

  private final ChildProfileRepository children;
  private final LessonProgressRepository progress;
  private final ChildStreakRepository streaks;
  private final BadgeRepository badges;
  private final ChildBadgeRepository childBadges;

  public BadgeService(
      ChildProfileRepository children,
      LessonProgressRepository progress,
      ChildStreakRepository streaks,
      BadgeRepository badges,
      ChildBadgeRepository childBadges) {
    this.children = children;
    this.progress = progress;
    this.streaks = streaks;
    this.badges = badges;
    this.childBadges = childBadges;
  }

  /** Called after any reward-worthy event; checks every badge criterion and awards whichever newly qualify. */
  @Transactional
  public List<Badge> evaluateAndAward(UUID childId) {
    List<Badge> newlyAwarded = new ArrayList<>();
    awardIfEligible(childId, FIRST_STEPS, hasCompletedAtLeastOneLesson(childId)).ifPresent(newlyAwarded::add);
    awardIfEligible(childId, FIVE_DAY_STREAK, hasFiveDayStreak(childId)).ifPresent(newlyAwarded::add);
    return newlyAwarded;
  }

  @Transactional(readOnly = true)
  public List<ChildBadge> listEarned(UUID parentId, UUID childId) {
    if (!children.belongsToParent(childId, parentId)) {
      throw new ChildNotFoundException();
    }
    return childBadges.findByChildId(childId);
  }

  private Optional<Badge> awardIfEligible(UUID childId, String badgeCode, boolean eligible) {
    if (!eligible || childBadges.exists(childId, badgeCode)) {
      return Optional.empty();
    }
    return badges.findByCode(badgeCode).map(badge -> {
      childBadges.save(new ChildBadge(childId, badgeCode, Instant.now()));
      return badge;
    });
  }

  private boolean hasCompletedAtLeastOneLesson(UUID childId) {
    return progress.findByChildId(childId).stream().anyMatch(LessonProgress::completed);
  }

  private boolean hasFiveDayStreak(UUID childId) {
    return streaks.findByChildId(childId).map(ChildStreak::currentStreak).orElse(0) >= 5;
  }
}
