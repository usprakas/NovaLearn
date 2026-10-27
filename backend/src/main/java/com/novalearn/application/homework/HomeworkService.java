package com.novalearn.application.homework;

import com.novalearn.application.ai.AiTextClient;
import com.novalearn.application.ai.ContentSafetyFilter;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.homework.HomeworkGuidance;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Takes an already-typed homework question — this is deliberately NOT an OCR/image pipeline;
 * NovaLearn's "homework scanner" vision from the PRD needs a vision/OCR API this environment has
 * no credentials for, so the mobile client asks the parent or child to type the question instead.
 * See RISKS_AND_TRADEOFFS.md. The actual guidance generation follows the same offline/real-LLM
 * split, and the same input/output content-safety treatment, as
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
    return aiClient
        .flatMap(client -> tryComplete(client, buildPrompt(question)))
        .map(this::fromAiResponse)
        .orElseGet(() -> offlineGuidance(question));
  }

  private Optional<String> tryComplete(AiTextClient client, String prompt) {
    try {
      String response = client.complete(prompt);
      if (!ContentSafetyFilter.isSafe(response)) {
        return Optional.empty();
      }
      return Optional.of(ContentSafetyFilter.capLength(response));
    } catch (RuntimeException aiCallFailed) {
      return Optional.empty();
    }
  }

  private String buildPrompt(String question) {
    return "A parent typed this homework question exactly as written on their child's worksheet: \""
        + question + "\". Write 3-5 short, numbered, child-friendly guidance steps that build "
        + "understanding (do not just give the final answer), one per line, followed by a short "
        + "encouraging closing hint on its own line. Plain sentences only — no markdown, no asterisks, "
        + "no bullet characters — just the number and a period before each step, since this is "
        + "displayed as plain text. Keep every step short.";
  }

  private HomeworkGuidance fromAiResponse(String raw) {
    List<String> lines = Arrays.stream(raw.split("\\r?\\n"))
        .map(String::trim)
        .filter(line -> !line.isEmpty())
        .toList();
    if (lines.isEmpty()) {
      return new HomeworkGuidance(List.of(raw), "You can do this!");
    }
    if (lines.size() == 1) {
      return new HomeworkGuidance(lines, "You can do this!");
    }
    String hint = lines.get(lines.size() - 1);
    List<String> steps = lines.subList(0, lines.size() - 1);
    return new HomeworkGuidance(steps, hint);
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
