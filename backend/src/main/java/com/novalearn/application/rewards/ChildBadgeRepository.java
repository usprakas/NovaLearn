package com.novalearn.application.rewards;

import com.novalearn.domain.rewards.ChildBadge;
import java.util.List;
import java.util.UUID;

public interface ChildBadgeRepository {
  boolean exists(UUID childId, String badgeCode);

  ChildBadge save(ChildBadge childBadge);

  List<ChildBadge> findByChildId(UUID childId);
}
