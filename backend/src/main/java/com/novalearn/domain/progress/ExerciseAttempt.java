package com.novalearn.domain.progress;

import java.time.Instant;
import java.util.UUID;

public record ExerciseAttempt(UUID id, UUID childId, UUID exerciseId, int submittedAnswerIndex, boolean correct, Instant attemptedAt) { }
