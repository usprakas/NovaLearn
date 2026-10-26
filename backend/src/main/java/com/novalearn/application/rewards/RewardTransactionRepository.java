package com.novalearn.application.rewards;

import com.novalearn.domain.rewards.RewardTransaction;
import java.util.UUID;

public interface RewardTransactionRepository {
  RewardTransaction save(RewardTransaction transaction);

  boolean existsByReferenceTypeAndReferenceId(String referenceType, String referenceId);

  int sumCoinsForChild(UUID childId);
}
