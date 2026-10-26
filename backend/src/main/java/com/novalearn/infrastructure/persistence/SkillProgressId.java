package com.novalearn.infrastructure.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.util.UUID;

@Embeddable
public record SkillProgressId(
    @Column(name = "child_id") UUID childId,
    @Column(name = "skill_code", length = 20) String skillCode) implements Serializable { }
