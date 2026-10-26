package com.novalearn.domain.catalog;

import java.util.List;
import java.util.UUID;

/**
 * The public-facing shape of an exercise — deliberately has no answer-index field. Evaluating a
 * submitted answer happens server-side via {@code application.progress.ExerciseEvaluationService},
 * which reads the correct answer through a narrower, non-public repository accessor instead of
 * this record, so the answer key can never be accidentally serialized into an API response.
 */
public record Exercise(UUID id, String lessonCode, String skillCode, int order, String prompt, List<String> choices) { }
