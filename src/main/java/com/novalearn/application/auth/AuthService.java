package com.novalearn.application.auth;

import com.novalearn.domain.auth.Role;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Locale;
import java.util.UUID;

@Service
public class AuthService {
    private final ParentAccountRepository accounts; private final PasswordHasher passwords; private final TokenService tokens;
    public AuthService(ParentAccountRepository accounts, PasswordHasher passwords, TokenService tokens) { this.accounts = accounts; this.passwords = passwords; this.tokens = tokens; }
    @Transactional
    public AuthResult register(String email, String password) {
        String normalizedEmail = email.trim().toLowerCase(Locale.ROOT);
        if (accounts.existsByEmail(normalizedEmail)) throw new EmailAlreadyRegisteredException();
        ParentAccount parent = accounts.save(new ParentAccount(UUID.randomUUID(), normalizedEmail, passwords.hash(password), Role.PARENT));
        return new AuthResult(parent.id(), parent.email(), tokens.issue(parent.id(), parent.role()));
    }
    @Transactional(readOnly = true)
    public AuthResult authenticate(String email, String password) {
        ParentAccount parent = accounts.findByEmail(email.trim().toLowerCase(Locale.ROOT)).orElseThrow(AuthenticationException::new);
        if (!passwords.matches(password, parent.passwordHash())) throw new AuthenticationException();
        return new AuthResult(parent.id(), parent.email(), tokens.issue(parent.id(), parent.role()));
    }
    public record AuthResult(UUID parentId, String email, String accessToken) { }
}
