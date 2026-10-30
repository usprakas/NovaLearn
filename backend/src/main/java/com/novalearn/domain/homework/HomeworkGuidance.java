package com.novalearn.domain.homework;

import java.util.List;

/**
 * Homework help for one question. {@code workedSteps}/{@code finalAnswer} carry a real worked
 * solution (each step's explanation plus its math and result) when an AI provider solved it;
 * they are empty/null for the offline fallback, which can only offer general guidance.
 * {@code steps}/{@code finalHint} are always filled — a plain-text rendering older clients use.
 */
public record HomeworkGuidance(
    List<String> steps, String finalHint, List<WorkedStep> workedSteps, String finalAnswer) {

  public HomeworkGuidance(List<String> steps, String finalHint) {
    this(steps, finalHint, List.of(), null);
  }

  /** {@code work} is the math for this step and its result (e.g. "C = 12 + 3 x 5 = 27"); may be null. */
  public record WorkedStep(String explanation, String work) { }
}
