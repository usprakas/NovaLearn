package com.novalearn.domain.auth;

import java.time.Instant;
import java.util.UUID;

/**
 * {@code tokenHash} is a SHA-256 digest of the raw refresh token; the raw value is handed to the
 * client exactly once (at issuance/rotation) and is never persisted or logged.
 */
public record RefreshToken(UUID id, UUID parentId, String tokenHash, Instant issuedAt, Instant expiresAt, boolean revoked) {

  public boolean isValid(Instant now) {
    return !revoked && expiresAt.isAfter(now);
  }
}
