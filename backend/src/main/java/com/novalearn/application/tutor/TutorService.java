package com.novalearn.application.tutor;

import com.novalearn.application.ai.AiTextClient;
import com.novalearn.application.ai.ContentSafetyFilter;
import com.novalearn.application.catalog.LessonCatalogService;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.catalog.LessonDefinition;
import com.novalearn.domain.child.ChildProfile;
import com.novalearn.domain.child.GradeLevel;
import com.novalearn.domain.tutor.TutorAnswer;
import com.novalearn.domain.tutor.TutorStrategy;
import java.util.List;
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
 *
 * <p>Both the question and (if a real client is configured) the model's own response pass through
 * {@link ContentSafetyFilter} — the model's output is untrusted input, not a trusted source, and
 * a flagged question never reaches the AI client or offline template at all; it gets a safe
 * redirect instead.
 */
@Service
public class TutorService {

  private final ChildProfileRepository children;
  private final Optional<AiTextClient> aiClient;
  private final LessonCatalogService catalog;

  public TutorService(ChildProfileRepository children, Optional<AiTextClient> aiClient, LessonCatalogService catalog) {
    this.children = children;
    this.aiClient = aiClient;
    this.catalog = catalog;
  }

  @Transactional(readOnly = true)
  public TutorAnswer ask(UUID parentId, UUID childId, String question, String subject, int attempt) {
    ChildProfile child = children.findById(childId)
        .filter(c -> c.parentId().equals(parentId))
        .orElseThrow(ChildNotFoundException::new);
    String normalizedQuestion = question == null ? "" : question.trim();
    if (normalizedQuestion.isEmpty()) {
      throw new InvalidTutorQuestionException();
    }
    TutorStrategy strategy = TutorStrategy.forAttempt(attempt);

    if (!ContentSafetyFilter.isSafe(normalizedQuestion)) {
      return new TutorAnswer(
          strategy, safeRedirectMessage(), suggestedNextActivity(subject, child.gradeLevel()), true);
    }

    String explanation = aiClient
        .flatMap(client -> tryComplete(client, buildPrompt(strategy, subject, normalizedQuestion)))
        .orElseGet(() -> offlineExplanation(strategy, normalizedQuestion));
    return new TutorAnswer(strategy, explanation, suggestedNextActivity(subject, child.gradeLevel()), false);
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

  private String buildPrompt(TutorStrategy strategy, String subject, String question) {
    String strategyGuidance = strategy == TutorStrategy.VISUAL_ANALOGY
        ? "Explain using a visual approach — since no real picture can be drawn here, build the "
            + "explanation out of simple emoji or symbols arranged in rows/groups right in the text "
            + "(for example: 2 apples plus 3 apples could be written as \"2 apples + 3 apples\" "
            + "using an apple emoji repeated the right number of times), so the child can still see "
            + "the quantities laid out rather than just reading numbers."
        : "Explain using a " + strategy.name().toLowerCase(Locale.ROOT) + " approach, in simple words.";
    return "You are a patient, encouraging tutor for a child aged 3-10. Subject: "
        + (subject == null ? "general" : subject) + ". " + strategyGuidance
        + " Never be scary or negative. Write in plain sentences only — "
        + "no markdown, no asterisks, no bullet points, no headers, since this is displayed as plain text. "
        + "Keep the whole answer under 150 words so it fits on a small screen without being cut off. "
        + "The child's question: " + question;
  }

  private String safeRedirectMessage() {
    return "That's not something NovaLearn can help with right now. Let's talk about math or "
        + "reading instead - ask me about a number, a word, or a lesson you're working on!";
  }

  private String suggestedNextActivity(String subject, GradeLevel gradeLevel) {
    List<LessonDefinition> lessons = catalog.forGrade(gradeLevel);
    return lessons.stream()
        .filter(lesson -> subject == null || lesson.subject().equalsIgnoreCase(subject))
        .findFirst()
        .or(() -> lessons.stream().findFirst())
        .map(lesson -> "Want more practice? Try the lesson \"" + lesson.title() + "\" in the Learn tab!")
        .orElse(null);
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
      case VISUAL_ANALOGY -> "Let's see this with symbols instead of just numbers: \"" + question + "\" — "
          + "try drawing one dot, star, or emoji for each thing you're counting or comparing, like ⭐⭐⭐ "
          + "for the number three, then count the shapes together. Seeing the groups laid out can make "
          + "it click faster than just reading the numbers.";
      case GUIDED_QUESTION -> "Let's figure this out together with a question: looking at \""
          + question + "\", what do you already know, and what is it asking you to find? Try answering "
          + "that first, one small piece at a time.";
    };
  }
}
