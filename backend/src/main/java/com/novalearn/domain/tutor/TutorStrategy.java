package com.novalearn.domain.tutor;

/** NovaLearn "tries another approach" by rotating through these when a child asks again. */
public enum TutorStrategy {
  STEP_BY_STEP,
  STORY,
  REAL_LIFE_EXAMPLE,
  VISUAL_ANALOGY,
  GUIDED_QUESTION;

  public static TutorStrategy forAttempt(int attempt) {
    TutorStrategy[] strategies = values();
    return strategies[Math.floorMod(attempt, strategies.length)];
  }
}
