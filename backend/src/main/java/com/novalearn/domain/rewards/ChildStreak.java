package com.novalearn.domain.rewards;

import java.time.LocalDate;
import java.util.UUID;

/** Streak state only — coins are no longer stored here, they are the sum of {@link RewardTransaction} rows (an auditable ledger). */
public record ChildStreak(UUID childId, int currentStreak, int longestStreak, LocalDate lastActivityDate) {

  public static ChildStreak initial(UUID childId) {
    return new ChildStreak(childId, 0, 0, null);
  }
}
