package com.novalearn.domain.progress;

import java.time.Instant; import java.util.UUID;
public record LessonProgress(UUID id, UUID childId, String lessonCode, int score, boolean completed, Instant updatedAt) { }
