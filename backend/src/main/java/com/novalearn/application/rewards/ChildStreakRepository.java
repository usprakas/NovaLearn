package com.novalearn.application.rewards;

import com.novalearn.domain.rewards.ChildStreak;
import java.util.Optional;
import java.util.UUID;

public interface ChildStreakRepository {
  Optional<ChildStreak> findByChildId(UUID childId);

  ChildStreak save(ChildStreak streak);
}
