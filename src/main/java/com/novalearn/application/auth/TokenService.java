package com.novalearn.application.auth;

import com.novalearn.domain.auth.Role;
import java.util.UUID;

public interface TokenService { String issue(UUID subject, Role role); }
