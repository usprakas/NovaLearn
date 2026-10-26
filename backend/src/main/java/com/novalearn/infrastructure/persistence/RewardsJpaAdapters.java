package com.novalearn.infrastructure.persistence;

import com.novalearn.application.rewards.BadgeRepository;
import com.novalearn.application.rewards.ChildBadgeRepository;
import com.novalearn.application.rewards.ChildStreakRepository;
import com.novalearn.application.rewards.RewardTransactionRepository;
import com.novalearn.domain.rewards.Badge;
import com.novalearn.domain.rewards.ChildBadge;
import com.novalearn.domain.rewards.ChildStreak;
import com.novalearn.domain.rewards.RewardTransaction;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.stereotype.Repository;

@Repository
class JpaChildStreakAdapter implements ChildStreakRepository {
  private final ChildStreakJpaRepository repo;

  JpaChildStreakAdapter(ChildStreakJpaRepository repo) {
    this.repo = repo;
  }

  @Override
  public Optional<ChildStreak> findByChildId(UUID childId) {
    return repo.findById(childId).map(JpaChildStreakAdapter::map);
  }

  @Override
  public ChildStreak save(ChildStreak streak) {
    ChildStreakEntity saved = repo.save(new ChildStreakEntity(
        streak.childId(), streak.currentStreak(), streak.longestStreak(), streak.lastActivityDate()));
    return map(saved);
  }

  private static ChildStreak map(ChildStreakEntity e) {
    return new ChildStreak(e.getChildId(), e.getCurrentStreak(), e.getLongestStreak(), e.getLastActivityDate());
  }
}

@Repository
class JpaRewardTransactionAdapter implements RewardTransactionRepository {
  private final RewardTransactionJpaRepository repo;

  JpaRewardTransactionAdapter(RewardTransactionJpaRepository repo) {
    this.repo = repo;
  }

  @Override
  public RewardTransaction save(RewardTransaction transaction) {
    RewardTransactionEntity saved = repo.save(new RewardTransactionEntity(
        transaction.id(), transaction.childId(), transaction.deltaCoins(), transaction.reason(),
        transaction.referenceType(), transaction.referenceId(), transaction.createdAt()));
    return map(saved);
  }

  @Override
  public boolean existsByReferenceTypeAndReferenceId(String referenceType, String referenceId) {
    return repo.existsByReferenceTypeAndReferenceId(referenceType, referenceId);
  }

  @Override
  public int sumCoinsForChild(UUID childId) {
    Integer sum = repo.sumDeltaCoinsByChildId(childId);
    return sum == null ? 0 : sum;
  }

  private static RewardTransaction map(RewardTransactionEntity e) {
    return new RewardTransaction(e.getId(), e.getChildId(), e.getDeltaCoins(), e.getReason(), e.getReferenceType(), e.getReferenceId(), e.getCreatedAt());
  }
}

@Repository
class JpaBadgeAdapter implements BadgeRepository {
  private final BadgeJpaRepository repo;

  JpaBadgeAdapter(BadgeJpaRepository repo) {
    this.repo = repo;
  }

  @Override
  public Optional<Badge> findByCode(String code) {
    return repo.findById(code).map(e -> new Badge(e.getCode(), e.getName(), e.getDescription()));
  }
}

@Repository
class JpaChildBadgeAdapter implements ChildBadgeRepository {
  private final ChildBadgeJpaRepository repo;

  JpaChildBadgeAdapter(ChildBadgeJpaRepository repo) {
    this.repo = repo;
  }

  @Override
  public boolean exists(UUID childId, String badgeCode) {
    return repo.existsById(new ChildBadgeId(childId, badgeCode));
  }

  @Override
  public ChildBadge save(ChildBadge childBadge) {
    ChildBadgeEntity saved = repo.save(new ChildBadgeEntity(childBadge.childId(), childBadge.badgeCode(), childBadge.awardedAt()));
    return map(saved);
  }

  @Override
  public List<ChildBadge> findByChildId(UUID childId) {
    return repo.findByIdChildId(childId).stream().map(JpaChildBadgeAdapter::map).toList();
  }

  private static ChildBadge map(ChildBadgeEntity e) {
    return new ChildBadge(e.getChildId(), e.getBadgeCode(), e.getAwardedAt());
  }
}
