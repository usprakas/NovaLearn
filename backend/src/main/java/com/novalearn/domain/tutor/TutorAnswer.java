package com.novalearn.domain.tutor;

/**
 * {@code refused} is true when the question tripped the content-safety filter (see
 * {@code application.ai.ContentSafetyFilter}) — {@code explanation} is then a safe redirect
 * message, not an attempt to answer. {@code suggestedNextActivity} is a plain-text nudge toward
 * a real catalog lesson, never a claim of personalized recommendation.
 */
public record TutorAnswer(TutorStrategy strategy, String explanation, String suggestedNextActivity, boolean refused) { }
