package com.novalearn.domain.rewards;

import java.time.Instant;
import java.util.UUID;

public record ChildBadge(UUID childId, String badgeCode, Instant awardedAt) { }
