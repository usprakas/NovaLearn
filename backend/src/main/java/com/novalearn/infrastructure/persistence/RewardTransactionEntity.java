package com.novalearn.infrastructure.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "reward_transactions", uniqueConstraints =
    @UniqueConstraint(name = "uk_reward_transactions_reference", columnNames = {"reference_type", "reference_id"}))
public class RewardTransactionEntity {
  @Id
  private UUID id;
  @Column(name = "child_id", nullable = false)
  private UUID childId;
  @Column(name = "delta_coins", nullable = false)
  private int deltaCoins;
  @Column(nullable = false, length = 200)
  private String reason;
  @Column(name = "reference_type", nullable = false, length = 50)
  private String referenceType;
  @Column(name = "reference_id", nullable = false, length = 100)
  private String referenceId;
  @Column(name = "created_at", nullable = false)
  private Instant createdAt;

  protected RewardTransactionEntity() { }

  public RewardTransactionEntity(UUID id, UUID childId, int deltaCoins, String reason, String referenceType, String referenceId, Instant createdAt) {
    this.id = id;
    this.childId = childId;
    this.deltaCoins = deltaCoins;
    this.reason = reason;
    this.referenceType = referenceType;
    this.referenceId = referenceId;
    this.createdAt = createdAt;
  }

  public UUID getId() { return id; }
  public UUID getChildId() { return childId; }
  public int getDeltaCoins() { return deltaCoins; }
  public String getReason() { return reason; }
  public String getReferenceType() { return referenceType; }
  public String getReferenceId() { return referenceId; }
  public Instant getCreatedAt() { return createdAt; }
}
