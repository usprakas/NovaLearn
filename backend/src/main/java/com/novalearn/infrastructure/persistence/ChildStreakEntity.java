package com.novalearn.infrastructure.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "child_streaks")
public class ChildStreakEntity {
  @Id
  @Column(name = "child_id")
  private UUID childId;
  @Column(name = "current_streak", nullable = false)
  private int currentStreak;
  @Column(name = "longest_streak", nullable = false)
  private int longestStreak;
  @Column(name = "last_activity_date")
  private LocalDate lastActivityDate;

  protected ChildStreakEntity() { }

  public ChildStreakEntity(UUID childId, int currentStreak, int longestStreak, LocalDate lastActivityDate) {
    this.childId = childId;
    this.currentStreak = currentStreak;
    this.longestStreak = longestStreak;
    this.lastActivityDate = lastActivityDate;
  }

  public UUID getChildId() { return childId; }
  public int getCurrentStreak() { return currentStreak; }
  public int getLongestStreak() { return longestStreak; }
  public LocalDate getLastActivityDate() { return lastActivityDate; }
}
