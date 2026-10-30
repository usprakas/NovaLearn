package com.novalearn.application.homework;

import com.novalearn.application.ai.AiTextClient;
import com.novalearn.application.ai.ContentSafetyFilter;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.child.ChildProfile;
import com.novalearn.domain.child.GradeLevel;
import com.novalearn.domain.homework.HomeworkGuidance;
import com.novalearn.domain.homework.HomeworkGuidance.WorkedStep;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Explains a homework question given as text — typed, spoken, or transcribed from a photo by
 * {@link HomeworkScanService} and then confirmed by the user. Guidance generation follows the
 * same offline/real-LLM split, and the same input/output content-safety treatment, as
 * {@link com.novalearn.application.tutor.TutorService}.
 */
@Service
public class HomeworkService {

  private final ChildProfileRepository children;
  private final Optional<AiTextClient> aiClient;

  public HomeworkService(ChildProfileRepository children, Optional<AiTextClient> aiClient) {
    this.children = children;
    this.aiClient = aiClient;
  }

  @Transactional(readOnly = true)
  public HomeworkGuidance explain(UUID parentId, UUID childId, String questionText) {
    if (!children.belongsToParent(childId, parentId)) {
      throw new ChildNotFoundException();
    }
    String question = questionText == null ? "" : questionText.trim();
    if (question.isEmpty()) {
      throw new InvalidHomeworkQuestionException();
    }
    if (!ContentSafetyFilter.isSafe(question)) {
      return new HomeworkGuidance(
          List.of("That question isn't something NovaLearn can help with."),
          "Ask a parent, or try a different homework question!");
    }
    Optional<GradeLevel> grade = children.findById(childId).map(ChildProfile::gradeLevel);
    return aiClient
        .flatMap(client -> tryComplete(client, buildPrompt(question, grade)))
        .map(this::fromAiResponse)
        .orElseGet(() -> offlineGuidance(question));
  }

  /**
   * Safety-checks the whole raw response, but does not length-cap it here: a worked solution is
   * capped per field after parsing ({@link #workedSolution}), so a long answer loses detail rather
   * than having its ANSWER line cut off.
   */
  private Optional<String> tryComplete(AiTextClient client, String prompt) {
    try {
      String response = client.complete(prompt);
      if (response == null || !ContentSafetyFilter.isSafe(response)) {
        return Optional.empty();
      }
      return Optional.of(response);
    } catch (RuntimeException aiCallFailed) {
      return Optional.empty();
    }
  }

  private String buildPrompt(String question, Optional<GradeLevel> grade) {
    String audience = grade.map(g -> "a " + gradeLabel(g) + " student").orElse("an elementary-school student");
    return "Solve this homework question and teach the solution to " + audience + ", step by step: \""
        + question + "\"\n"
        + "Show the actual work and the result of every step, and give the final answer. Explain each "
        + "step in simple, friendly words, saying what we do and why.\n"
        + "Reply in exactly this format, one item per line, nothing else:\n"
        + "STEP: <one or two short sentences explaining this step> | <the math for this step and its result>\n"
        + "(3 to 6 STEP lines; leave out the \"| ...\" part only if a step has no math)\n"
        + "ANSWER: <the final answer, with units if there are any>\n"
        + "TIP: <one short encouraging sentence>\n"
        + "Write math with plain characters (x for times, / for divide, ^ for powers) — no LaTeX, no "
        + "markdown, no asterisks. Double-check the arithmetic before answering.";
  }

  private static String gradeLabel(GradeLevel grade) {
    return switch (grade.name()) {
      case "PRE_K" -> "Pre-K";
      case "KINDERGARTEN" -> "Kindergarten";
      default -> "Grade " + grade.name().substring(grade.name().lastIndexOf('_') + 1);
    };
  }

  private static final Pattern STEP_LINE = Pattern.compile("^(?:\\d+[.)]\\s*)?STEP\\s*\\d*\\s*:\\s*(.+)$", Pattern.CASE_INSENSITIVE);
  private static final Pattern ANSWER_LINE = Pattern.compile("^(?:FINAL\\s+)?ANSWER\\s*:\\s*(.+)$", Pattern.CASE_INSENSITIVE);
  private static final Pattern TIP_LINE = Pattern.compile("^TIP\\s*:\\s*(.+)$", Pattern.CASE_INSENSITIVE);
  /** "1. ", "2) ", "Step 3: " — the UI numbers steps itself, so a model's own numbering is dropped. */
  private static final Pattern LEADING_NUMBER = Pattern.compile("^(?:step\\s*)?\\d+\\s*[.):-]\\s*", Pattern.CASE_INSENSITIVE);
  private static final int MAX_STEPS = 8;
  private static final int MAX_EXPLANATION = 300;
  private static final int MAX_WORK = 200;

  private HomeworkGuidance fromAiResponse(String raw) {
    List<String> lines = Arrays.stream(raw.split("\\r?\\n"))
        .map(String::trim)
        .filter(line -> !line.isEmpty())
        .toList();
    HomeworkGuidance worked = workedSolution(lines);
    if (worked != null) {
      return worked;
    }
    // The model ignored the format: fall back to treating each line as a plain step.
    lines = Arrays.stream(ContentSafetyFilter.capLength(raw).split("\\r?\\n"))
        .map(String::trim)
        .filter(line -> !line.isEmpty())
        .map(line -> LEADING_NUMBER.matcher(line).replaceFirst(""))
        .toList();
    if (lines.isEmpty()) {
      return new HomeworkGuidance(List.of(ContentSafetyFilter.capLength(raw)), "You can do this!");
    }
    if (lines.size() == 1) {
      return new HomeworkGuidance(lines, "You can do this!");
    }
    String hint = lines.get(lines.size() - 1);
    List<String> steps = lines.subList(0, lines.size() - 1);
    return new HomeworkGuidance(steps, hint);
  }

  /** Parses the STEP/ANSWER/TIP format; null if the response doesn't contain a worked solution. */
  private HomeworkGuidance workedSolution(List<String> lines) {
    List<WorkedStep> worked = new ArrayList<>();
    String answer = null;
    String tip = null;
    for (String line : lines) {
      Matcher step = STEP_LINE.matcher(line);
      Matcher ans = ANSWER_LINE.matcher(line);
      Matcher tipLine = TIP_LINE.matcher(line);
      if (step.matches() && worked.size() < MAX_STEPS) {
        String body = step.group(1).trim();
        // First " | " separates explanation from work, so math like |x| inside the work survives.
        int bar = body.indexOf(" | ");
        String explanation = (bar >= 0 ? body.substring(0, bar) : body).trim();
        String work = bar >= 0 ? body.substring(bar + 3).trim() : "";
        if (!explanation.isEmpty()) {
          worked.add(new WorkedStep(cap(explanation, MAX_EXPLANATION), work.isEmpty() ? null : cap(work, MAX_WORK)));
        }
      } else if (ans.matches() && answer == null) {
        answer = cap(ans.group(1).trim(), MAX_WORK);
      } else if (tipLine.matches() && tip == null) {
        tip = cap(tipLine.group(1).trim(), MAX_EXPLANATION);
      }
    }
    if (worked.isEmpty() || answer == null) {
      return null;
    }
    List<String> plainSteps = worked.stream()
        .map(w -> w.work() == null ? w.explanation() : w.explanation() + " " + w.work())
        .toList();
    String hint = tip != null ? tip : "Great work following along!";
    return new HomeworkGuidance(plainSteps, "Answer: " + answer + ". " + hint, worked, answer);
  }

  private static String cap(String text, int max) {
    return text.length() <= max ? text : text.substring(0, max - 3).trim() + "...";
  }

  private HomeworkGuidance offlineGuidance(String question) {
    List<String> steps = List.of(
        "Read the question slowly and underline any numbers or key words: \"" + question + "\"",
        "Figure out what the question is actually asking you to find.",
        "Write down what you already know, then try one small step at a time.",
        "Check your answer by reading the question again to see if it makes sense.");
    return new HomeworkGuidance(steps, "These are guided steps, not the final answer - that way the understanding sticks!");
  }
}
