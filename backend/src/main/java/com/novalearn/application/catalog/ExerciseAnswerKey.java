package com.novalearn.application.catalog;

/**
 * The part of an exercise that must never be serialized into a client-facing response. Returned
 * only to {@code application.progress.ExerciseEvaluationService}, never to a controller.
 */
public record ExerciseAnswerKey(String skillCode, int correctAnswerIndex, String explanation, String hint) { }
