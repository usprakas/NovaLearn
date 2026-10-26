package com.novalearn.domain.progress;

/** {@code hint} is non-null only when the submitted answer was incorrect. */
public record ExerciseEvaluation(boolean correct, String explanation, String hint) { }
