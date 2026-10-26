package com.novalearn.application.auth;

import java.util.Optional;
import java.util.UUID;

public interface ParentAccountRepository {
    boolean existsByEmail(String email);
    ParentAccount save(ParentAccount account);
    Optional<ParentAccount> findByEmail(String email);
    Optional<ParentAccount> findById(UUID id);
}
