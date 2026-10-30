package com.novalearn.application.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.novalearn.domain.auth.RefreshToken;
import com.novalearn.domain.auth.Role;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.transaction.annotation.Transactional;

class AuthServiceTest {

  private final ParentAccountRepository accounts = mock(ParentAccountRepository.class);
  private final PasswordHasher passwords = mock(PasswordHasher.class);
  private final TokenService tokens = mock(TokenService.class);
  private final RefreshTokenRepository refreshTokens = mock(RefreshTokenRepository.class);
  private final AuthService service = new AuthService(accounts, passwords, tokens, refreshTokens, 30);

  @Test
  void registers_normalized_email_and_issues_an_access_and_refresh_token() {
    when(accounts.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
    when(tokens.issue(any(), eq(Role.PARENT))).thenReturn("access-token");
    when(passwords.hash("A secure password")).thenReturn("hash");
    when(refreshTokens.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    AuthService.AuthResult result = service.register("  PARENT@Example.COM ", "A secure password");

    assertThat(result.email()).isEqualTo("parent@example.com");
    assertThat(result.accessToken()).isEqualTo("access-token");
    assertThat(result.refreshToken()).isNotBlank();
    verify(passwords).hash("A secure password");
  }

  @Test
  void rejects_existing_email() {
    when(accounts.existsByEmail("parent@example.com")).thenReturn(true);

    assertThatThrownBy(() -> service.register("parent@example.com", "A secure password"))
        .isInstanceOf(EmailAlreadyRegisteredException.class);
    verifyNoInteractions(passwords, tokens, refreshTokens);
  }

  @Test
  void rejects_invalid_password_without_issuing_a_token() {
    ParentAccount parent = new ParentAccount(UUID.randomUUID(), "parent@example.com", "hash", Role.PARENT);
    when(accounts.findByEmail(parent.email())).thenReturn(Optional.of(parent));
    when(passwords.matches("wrong", parent.passwordHash())).thenReturn(false);

    assertThatThrownBy(() -> service.authenticate(parent.email(), "wrong")).isInstanceOf(AuthenticationException.class);
    verifyNoInteractions(tokens, refreshTokens);
  }

  @Test
  void does_not_distinguish_an_unknown_email() {
    when(accounts.findByEmail("missing@example.com")).thenReturn(Optional.empty());

    assertThatThrownBy(() -> service.authenticate("missing@example.com", "a password")).isInstanceOf(AuthenticationException.class);
    verifyNoInteractions(tokens, passwords);
  }

  @Test
  void rotatesARefreshTokenIntoANewAccessAndRefreshPair() {
    UUID parentId = UUID.randomUUID();
    ParentAccount parent = new ParentAccount(parentId, "parent@example.com", "hash", Role.PARENT);
    RefreshToken stored = new RefreshToken(UUID.randomUUID(), parentId, "irrelevant-in-this-test", Instant.now(), Instant.now().plusSeconds(60), false);
    when(refreshTokens.findByTokenHash(any())).thenReturn(Optional.of(stored));
    when(accounts.findById(parentId)).thenReturn(Optional.of(parent));
    when(tokens.issue(any(), any())).thenReturn("new-access-token");
    when(refreshTokens.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    AuthService.AuthResult result = service.refresh("some-raw-refresh-token");

    assertThat(result.accessToken()).isEqualTo("new-access-token");
    verify(refreshTokens).revoke(stored.id());
  }

  @Test
  void rejectsAnExpiredRefreshToken() {
    RefreshToken expired = new RefreshToken(UUID.randomUUID(), UUID.randomUUID(), "hash", Instant.now().minusSeconds(120), Instant.now().minusSeconds(60), false);
    when(refreshTokens.findByTokenHash(any())).thenReturn(Optional.of(expired));

    assertThatThrownBy(() -> service.refresh("expired-token")).isInstanceOf(AuthenticationException.class);
    verify(refreshTokens, never()).revoke(any());
  }

  @Test
  void rejectsAnAlreadyRevokedRefreshToken() {
    RefreshToken revoked = new RefreshToken(UUID.randomUUID(), UUID.randomUUID(), "hash", Instant.now(), Instant.now().plusSeconds(60), true);
    when(refreshTokens.findByTokenHash(any())).thenReturn(Optional.of(revoked));

    assertThatThrownBy(() -> service.refresh("revoked-token")).isInstanceOf(AuthenticationException.class);
  }

  @Test
  void rejectsAnUnknownRefreshToken() {
    when(refreshTokens.findByTokenHash(any())).thenReturn(Optional.empty());

    assertThatThrownBy(() -> service.refresh("unknown-token")).isInstanceOf(AuthenticationException.class);
  }

  @Test
  void logoutRevokesTheMatchingRefreshToken() {
    RefreshToken stored = new RefreshToken(UUID.randomUUID(), UUID.randomUUID(), "hash", Instant.now(), Instant.now().plusSeconds(60), false);
    when(refreshTokens.findByTokenHash(any())).thenReturn(Optional.of(stored));

    service.logout("some-raw-refresh-token");

    verify(refreshTokens).revoke(stored.id());
  }

  @Test
  void logoutIsANoOpForAnUnknownToken() {
    when(refreshTokens.findByTokenHash(any())).thenReturn(Optional.empty());

    service.logout("unknown-token");

    verify(refreshTokens, never()).revoke(any());
  }

  @Test
  void deletesTheAccountOnceThePasswordIsReconfirmed() {
    UUID parentId = UUID.randomUUID();
    ParentAccount parent = new ParentAccount(parentId, "parent@example.com", "hash", Role.PARENT);
    when(accounts.findById(parentId)).thenReturn(Optional.of(parent));
    when(passwords.matches("correct password", "hash")).thenReturn(true);

    service.deleteAccount(parentId, "correct password");

    verify(accounts).deleteById(parentId);
  }

  @Test
  void refusesToDeleteTheAccountWithTheWrongPassword() {
    UUID parentId = UUID.randomUUID();
    ParentAccount parent = new ParentAccount(parentId, "parent@example.com", "hash", Role.PARENT);
    when(accounts.findById(parentId)).thenReturn(Optional.of(parent));
    when(passwords.matches("wrong", "hash")).thenReturn(false);

    assertThatThrownBy(() -> service.deleteAccount(parentId, "wrong")).isInstanceOf(AuthenticationException.class);
    verify(accounts, never()).deleteById(any());
  }

  /**
   * Every method that issues a session persists a refresh token, so none may run in a read-only
   * transaction: Hibernate silently skips the flush, and the client gets a refresh token that was
   * never stored (login's tokens were all rejected by /auth/refresh until this was fixed). Mocked
   * repositories can't observe a missing flush, hence checking the annotation directly.
   */
  @Test
  void sessionIssuingMethodsAreNotReadOnlyTransactions() throws Exception {
    for (String method : new String[] {"register", "authenticate"}) {
      Transactional tx = AuthService.class.getMethod(method, String.class, String.class).getAnnotation(Transactional.class);
      assertThat(tx).as(method).isNotNull();
      assertThat(tx.readOnly()).as(method).isFalse();
    }
    Transactional refresh = AuthService.class.getMethod("refresh", String.class).getAnnotation(Transactional.class);
    assertThat(refresh.readOnly()).isFalse();
  }
}
