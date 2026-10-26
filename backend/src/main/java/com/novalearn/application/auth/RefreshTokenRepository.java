package com.novalearn.application.auth;

import com.novalearn.domain.auth.RefreshToken;
import java.util.Optional;
import java.util.UUID;

public interface RefreshTokenRepository {
  RefreshToken save(RefreshToken token);

  Optional<RefreshToken> findByTokenHash(String tokenHash);

  void revoke(UUID id);

  void revokeAllForParent(UUID parentId);
}
