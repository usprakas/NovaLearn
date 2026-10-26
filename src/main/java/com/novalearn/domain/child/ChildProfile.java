package com.novalearn.domain.child;

import java.time.LocalDate; import java.util.UUID;

public record ChildProfile(UUID id, UUID parentId, String displayName, LocalDate birthDate) { }
