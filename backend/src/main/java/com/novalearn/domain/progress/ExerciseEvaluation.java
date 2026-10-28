package com.novalearn.domain.progress;

/**
 * {@code hint} is non-null only when the submitted answer was incorrect. {@code correctChoiceText}
 * is the correct choice's own text (e.g. {@code "FRACTION:1:2:1/2"}) — safe to return here, unlike
 * from any pre-grading endpoint, because by this point the answer has already been graded and
 * {@code explanation} already states it in prose; this just lets the client draw the same picture
 * for the correct answer that it already draws for the exercise's choices.
 */
public record ExerciseEvaluation(boolean correct, String explanation, String hint, String correctChoiceText) { }
