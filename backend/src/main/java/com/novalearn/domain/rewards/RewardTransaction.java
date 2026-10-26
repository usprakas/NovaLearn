package com.novalearn.domain.rewards;

import java.time.Instant;
import java.util.UUID;

/**
 * An auditable ledger entry. {@code referenceType}+{@code referenceId} identify the event that
 * caused the award (e.g. {@code "LESSON_COMPLETION"} + the lesson_progress id); a unique
 * constraint on that pair at the database level prevents awarding the same event twice even if
 * the triggering request is retried.
 */
public record RewardTransaction(UUID id, UUID childId, int deltaCoins, String reason, String referenceType, String referenceId, Instant createdAt) { }
