package com.novalearn.domain.rewards;

import java.time.LocalDate;
import java.util.UUID;

public record ChildRewards(UUID childId, int coins, int currentStreak, int longestStreak, LocalDate lastActivityDate) {

  public static ChildRewards initial(UUID childId) {
    return new ChildRewards(childId, 0, 0, 0, null);
  }
}
