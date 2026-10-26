package com.novalearn.application.auth;

import java.util.Optional;

public interface ParentAccountRepository {
    boolean existsByEmail(String email);
    ParentAccount save(ParentAccount account);
    Optional<ParentAccount> findByEmail(String email);
}
