package com.novalearn.application.rewards;

import com.novalearn.domain.rewards.ChildRewards;
import java.util.Optional;
import java.util.UUID;

public interface ChildRewardsRepository {
  Optional<ChildRewards> findByChildId(UUID childId);

  ChildRewards save(ChildRewards rewards);
}
