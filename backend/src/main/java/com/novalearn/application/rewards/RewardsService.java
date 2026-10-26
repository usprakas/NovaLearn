package com.novalearn.application.rewards;

import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.rewards.ChildRewardsSummary;
import com.novalearn.domain.rewards.ChildStreak;
import com.novalearn.domain.rewards.RewardTransaction;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Coins are an auditable ledger ({@link RewardTransaction}), not a mutable accumulator: awarding
 * is idempotent on {@code (referenceType, referenceId)} — both an application-level check and a
 * database unique constraint, so a retried request can never award the same event twice even
 * under a race. Streaks remain separate stateful counters ({@link ChildStreak}), since "consecutive
 * days active" isn't naturally a ledger concept the way a coin amount is.
 */
@Service
public class RewardsService {

  private final RewardTransactionRepository transactions;
  private final ChildStreakRepository streaks;
  private final ChildProfileRepository children;
  private final BadgeService badges;
  private final Clock clock;

  public RewardsService(
      RewardTransactionRepository transactions,
      ChildStreakRepository streaks,
      ChildProfileRepository children,
      BadgeService badges,
      Clock clock) {
    this.transactions = transactions;
    this.streaks = streaks;
    this.children = children;
    this.badges = badges;
    this.clock = clock;
  }

  /**
   * Awards {@code deltaCoins}, advances the activity streak, and evaluates badges — all as a
   * no-op if {@code (referenceType, referenceId)} has already been awarded (first checked in
   * application code, then enforced by a unique constraint in case of a concurrent retry).
   */
  @Transactional
  public void award(UUID childId, int deltaCoins, String reason, String referenceType, String referenceId) {
    if (transactions.existsByReferenceTypeAndReferenceId(referenceType, referenceId)) {
      return;
    }
    try {
      transactions.save(new RewardTransaction(UUID.randomUUID(), childId, deltaCoins, reason, referenceType, referenceId, Instant.now(clock)));
    } catch (DataIntegrityViolationException alreadyAwardedConcurrently) {
      return;
    }
    advanceStreak(childId);
    badges.evaluateAndAward(childId);
  }

  @Transactional(readOnly = true)
  public ChildRewardsSummary get(UUID parentId, UUID childId) {
    if (!children.belongsToParent(childId, parentId)) {
      throw new ChildNotFoundException();
    }
    int coins = transactions.sumCoinsForChild(childId);
    ChildStreak streak = streaks.findByChildId(childId).orElse(ChildStreak.initial(childId));
    return new ChildRewardsSummary(coins, streak.currentStreak(), streak.longestStreak(), streak.lastActivityDate());
  }

  private void advanceStreak(UUID childId) {
    ChildStreak current = streaks.findByChildId(childId).orElse(ChildStreak.initial(childId));
    LocalDate today = LocalDate.now(clock);
    int currentStreak = nextStreak(current, today);
    int longestStreak = Math.max(current.longestStreak(), currentStreak);
    streaks.save(new ChildStreak(childId, currentStreak, longestStreak, today));
  }

  private int nextStreak(ChildStreak current, LocalDate today) {
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
