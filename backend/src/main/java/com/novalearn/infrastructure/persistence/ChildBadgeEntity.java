package com.novalearn.infrastructure.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "child_badges")
public class ChildBadgeEntity {
  @EmbeddedId
  private ChildBadgeId id;
  @Column(name = "awarded_at", nullable = false)
  private Instant awardedAt;

  protected ChildBadgeEntity() { }

  public ChildBadgeEntity(UUID childId, String badgeCode, Instant awardedAt) {
    this.id = new ChildBadgeId(childId, badgeCode);
    this.awardedAt = awardedAt;
  }

  public UUID getChildId() { return id.childId(); }
  public String getBadgeCode() { return id.badgeCode(); }
  public Instant getAwardedAt() { return awardedAt; }
}
