package com.novalearn.application.rewards;

import com.novalearn.domain.rewards.Badge;
import java.util.Optional;

public interface BadgeRepository {
  Optional<Badge> findByCode(String code);
}
