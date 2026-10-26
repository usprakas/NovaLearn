package com.novalearn.domain.progress;

import java.time.Instant;
import java.util.UUID;

/**
 * Deliberately simple and transparent: mastery is just the recent accuracy ratio, not a claim
 * about the child's overall ability. See docs/DATABASE_DESIGN.md "Mastery algorithm" for why.
 */
public record SkillProgress(UUID childId, String skillCode, int attemptsCount, int correctCount, Instant lastAttemptAt) {

  public static SkillProgress initial(UUID childId, String skillCode) {
    return new SkillProgress(childId, skillCode, 0, 0, null);
  }

  public double masteryRatio() {
    return attemptsCount == 0 ? 0.0 : (double) correctCount / attemptsCount;
  }
}
