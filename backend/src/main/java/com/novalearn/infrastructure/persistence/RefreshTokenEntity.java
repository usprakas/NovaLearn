package com.novalearn.infrastructure.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "refresh_tokens")
public class RefreshTokenEntity {
  @Id
  private UUID id;
  @Column(name = "parent_id", nullable = false)
  private UUID parentId;
  @Column(name = "token_hash", nullable = false, unique = true, length = 64)
  private String tokenHash;
  @Column(name = "issued_at", nullable = false)
  private Instant issuedAt;
  @Column(name = "expires_at", nullable = false)
  private Instant expiresAt;
  @Column(nullable = false)
  private boolean revoked;

  protected RefreshTokenEntity() { }

  public RefreshTokenEntity(UUID id, UUID parentId, String tokenHash, Instant issuedAt, Instant expiresAt, boolean revoked) {
    this.id = id;
    this.parentId = parentId;
    this.tokenHash = tokenHash;
    this.issuedAt = issuedAt;
    this.expiresAt = expiresAt;
    this.revoked = revoked;
  }

  public UUID getId() { return id; }
  public UUID getParentId() { return parentId; }
  public String getTokenHash() { return tokenHash; }
  public Instant getIssuedAt() { return issuedAt; }
  public Instant getExpiresAt() { return expiresAt; }
  public boolean isRevoked() { return revoked; }
  public void setRevoked(boolean revoked) { this.revoked = revoked; }
}
