package com.novalearn.application.tutor;

import com.novalearn.application.ai.AiTextClient;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.tutor.TutorAnswer;
import com.novalearn.domain.tutor.TutorStrategy;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * A child asks a question; if {@code ANTHROPIC_API_KEY} is set, a real explanation comes back
 * from {@link AiTextClient}. Otherwise NovaLearn answers with a deterministic, child-safe
 * template. Each repeated question (the mobile client's "try another way") advances to the next
 * {@link TutorStrategy} instead of repeating the same explanation.
 */
@Service
public class TutorService {

  private final ChildProfileRepository children;
  private final Optional<AiTextClient> aiClient;

  public TutorService(ChildProfileRepository children, Optional<AiTextClient> aiClient) {
    this.children = children;
    this.aiClient = aiClient;
  }

  @Transactional(readOnly = true)
  public TutorAnswer ask(UUID parentId, UUID childId, String question, String subject, int attempt) {
    if (!children.belongsToParent(childId, parentId)) {
      throw new ChildNotFoundException();
    }
    String normalizedQuestion = question == null ? "" : question.trim();
    if (normalizedQuestion.isEmpty()) {
      throw new InvalidTutorQuestionException();
    }
    TutorStrategy strategy = TutorStrategy.forAttempt(attempt);
    String explanation = aiClient
        .flatMap(client -> tryComplete(client, buildPrompt(strategy, subject, normalizedQuestion)))
        .orElseGet(() -> offlineExplanation(strategy, normalizedQuestion));
    return new TutorAnswer(strategy, explanation);
  }

  private Optional<String> tryComplete(AiTextClient client, String prompt) {
    try {
      return Optional.of(client.complete(prompt));
    } catch (RuntimeException aiCallFailed) {
      return Optional.empty();
    }
  }

  private String buildPrompt(TutorStrategy strategy, String subject, String question) {
    return "You are a patient, encouraging tutor for a child aged 3-10. Subject: "
        + (subject == null ? "general" : subject) + ". Explain using a " + strategy.name().toLowerCase(Locale.ROOT)
        + " approach, in simple words, without ever being scary or negative. The child's question: " + question;
  }

  private String offlineExplanation(TutorStrategy strategy, String question) {
    return switch (strategy) {
      case STEP_BY_STEP -> "Let's break it down step by step! First, read the question again: \""
          + question + "\" Now think about what it's really asking. Write down any numbers or "
          + "words you see, and solve one small part at a time before putting it all together.";
      case STORY -> "Here's a little story: imagine a curious character who runs into exactly this "
          + "puzzle — \"" + question + "\" — and solves it by counting on their fingers, drawing a "
          + "picture, or acting it out with toys. Try picturing the problem the same way!";
      case REAL_LIFE_EXAMPLE -> "Let's connect this to everyday life: \"" + question + "\". If it's "
          + "about numbers, imagine using toys or snacks to count; if it's about words, try saying "
          + "it out loud to a family member and see if that makes it click.";
    };
  }
}
