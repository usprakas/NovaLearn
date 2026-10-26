package com.novalearn.infrastructure.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "skill_progress")
public class SkillProgressEntity {
  @EmbeddedId
  private SkillProgressId id;
  @Column(name = "attempts_count", nullable = false)
  private int attemptsCount;
  @Column(name = "correct_count", nullable = false)
  private int correctCount;
  @Column(name = "last_attempt_at")
  private Instant lastAttemptAt;

  protected SkillProgressEntity() { }

  public SkillProgressEntity(UUID childId, String skillCode, int attemptsCount, int correctCount, Instant lastAttemptAt) {
    this.id = new SkillProgressId(childId, skillCode);
    this.attemptsCount = attemptsCount;
    this.correctCount = correctCount;
    this.lastAttemptAt = lastAttemptAt;
  }

  public UUID getChildId() { return id.childId(); }
  public String getSkillCode() { return id.skillCode(); }
  public int getAttemptsCount() { return attemptsCount; }
  public int getCorrectCount() { return correctCount; }
  public Instant getLastAttemptAt() { return lastAttemptAt; }
}
