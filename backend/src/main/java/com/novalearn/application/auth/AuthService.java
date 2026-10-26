package com.novalearn.application.auth;

import com.novalearn.domain.auth.RefreshToken;
import com.novalearn.domain.auth.Role;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Locale;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Issues a short-lived JWT access token plus a long-lived, single-use, rotating refresh token on
 * every register/login/refresh. The raw refresh token is returned to the client exactly once; only
 * its SHA-256 hash is ever persisted, so a database read alone can never recover a usable token.
 * Refresh tokens rotate on every use (the presented token is revoked, a new one is issued); the
 * old token's record stays in the table as a revoked audit trail rather than being deleted.
 */
@Service
public class AuthService {

  private static final SecureRandom RANDOM = new SecureRandom();

  private final ParentAccountRepository accounts;
  private final PasswordHasher passwords;
  private final TokenService tokens;
  private final RefreshTokenRepository refreshTokens;
  private final Duration refreshTokenTtl;

  public AuthService(
      ParentAccountRepository accounts,
      PasswordHasher passwords,
      TokenService tokens,
      RefreshTokenRepository refreshTokens,
      @Value("${novalearn.security.refresh-token-ttl-days:30}") long refreshTokenTtlDays) {
    this.accounts = accounts;
    this.passwords = passwords;
    this.tokens = tokens;
    this.refreshTokens = refreshTokens;
    this.refreshTokenTtl = Duration.ofDays(refreshTokenTtlDays);
  }

  @Transactional
  public AuthResult register(String email, String password) {
    String normalizedEmail = email.trim().toLowerCase(Locale.ROOT);
    if (accounts.existsByEmail(normalizedEmail)) {
      throw new EmailAlreadyRegisteredException();
    }
    ParentAccount parent = accounts.save(new ParentAccount(UUID.randomUUID(), normalizedEmail, passwords.hash(password), Role.PARENT));
    return issueSession(parent);
  }

  @Transactional(readOnly = true)
  public AuthResult authenticate(String email, String password) {
    ParentAccount parent = accounts.findByEmail(email.trim().toLowerCase(Locale.ROOT)).orElseThrow(AuthenticationException::new);
    if (!passwords.matches(password, parent.passwordHash())) {
      throw new AuthenticationException();
    }
    return issueSession(parent);
  }

  /** Validates and rotates a refresh token: the presented token is revoked and a new pair is issued. */
  @Transactional
  public AuthResult refresh(String rawRefreshToken) {
    RefreshToken current = refreshTokens.findByTokenHash(hash(rawRefreshToken)).orElseThrow(AuthenticationException::new);
    if (!current.isValid(Instant.now())) {
      throw new AuthenticationException();
    }
    refreshTokens.revoke(current.id());
    ParentAccount parent = accounts.findById(current.parentId()).orElseThrow(AuthenticationException::new);
    return issueSession(parent);
  }

  @Transactional
  public void logout(String rawRefreshToken) {
    refreshTokens.findByTokenHash(hash(rawRefreshToken)).ifPresent(token -> refreshTokens.revoke(token.id()));
  }

  /**
   * Permanently deletes the parent account after re-confirming the password. Every child profile,
   * their lesson progress, rewards, and refresh tokens cascade-delete at the database level
   * (see the {@code ON DELETE CASCADE} foreign keys from {@code child_profiles} and
   * {@code refresh_tokens} to {@code parent_accounts}) — there is nothing else to clean up here.
   */
  @Transactional
  public void deleteAccount(UUID parentId, String password) {
    ParentAccount parent = accounts.findById(parentId).orElseThrow(AuthenticationException::new);
    if (!passwords.matches(password, parent.passwordHash())) {
      throw new AuthenticationException();
    }
    accounts.deleteById(parentId);
  }

  private AuthResult issueSession(ParentAccount parent) {
    String accessToken = tokens.issue(parent.id(), parent.role());
    String rawRefreshToken = generateRawToken();
    Instant now = Instant.now();
    refreshTokens.save(new RefreshToken(UUID.randomUUID(), parent.id(), hash(rawRefreshToken), now, now.plus(refreshTokenTtl), false));
    return new AuthResult(parent.id(), parent.email(), accessToken, rawRefreshToken);
  }

  private String generateRawToken() {
    byte[] bytes = new byte[32];
    RANDOM.nextBytes(bytes);
    return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
  }

  private String hash(String rawToken) {
    try {
      return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(rawToken.getBytes(StandardCharsets.UTF_8)));
    } catch (NoSuchAlgorithmException impossible) {
      throw new IllegalStateException(impossible);
    }
  }

  public record AuthResult(UUID parentId, String email, String accessToken, String refreshToken) { }
}
