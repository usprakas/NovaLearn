package com.novalearn.application.auth;

import com.novalearn.domain.auth.Role;
import java.util.UUID;

public record ParentAccount(UUID id, String email, String passwordHash, Role role) { }
