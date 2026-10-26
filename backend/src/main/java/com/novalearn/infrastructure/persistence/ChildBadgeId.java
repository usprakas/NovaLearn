package com.novalearn.infrastructure.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.util.UUID;

@Embeddable
public record ChildBadgeId(
    @Column(name = "child_id") UUID childId,
    @Column(name = "badge_code", length = 50) String badgeCode) implements Serializable { }
