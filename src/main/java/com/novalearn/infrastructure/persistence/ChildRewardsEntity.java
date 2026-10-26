package com.novalearn.infrastructure.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "child_rewards")
public class ChildRewardsEntity {
  @Id
  @Column(name = "child_id")
  private UUID childId;
  @Column(nullable = false)
  private int coins;
  @Column(name = "current_streak", nullable = false)
  private int currentStreak;
  @Column(name = "longest_streak", nullable = false)
  private int longestStreak;
  @Column(name = "last_activity_date")
  private LocalDate lastActivityDate;

  protected ChildRewardsEntity() { }

  public ChildRewardsEntity(UUID childId, int coins, int currentStreak, int longestStreak, LocalDate lastActivityDate) {
    this.childId = childId;
    this.coins = coins;
    this.currentStreak = currentStreak;
    this.longestStreak = longestStreak;
    this.lastActivityDate = lastActivityDate;
  }

  public UUID getChildId() { return childId; }
  public int getCoins() { return coins; }
  public int getCurrentStreak() { return currentStreak; }
  public int getLongestStreak() { return longestStreak; }
  public LocalDate getLastActivityDate() { return lastActivityDate; }
}
