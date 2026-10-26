package com.novalearn.application.tutor;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.novalearn.application.ai.AiTextClient;
import com.novalearn.application.catalog.LessonCatalogService;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.catalog.LessonDefinition;
import com.novalearn.domain.tutor.TutorAnswer;
import com.novalearn.domain.tutor.TutorStrategy;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class TutorServiceTest {

  private final LessonCatalogService catalog = mock(LessonCatalogService.class);

  @Test
  void answersOfflineWithAnIncreasinglyDifferentStrategyOnEachAttempt() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(catalog.all()).thenReturn(List.of());
    TutorService service = new TutorService(children, Optional.empty(), catalog);

    TutorAnswer first = service.ask(parent, child, "What is 2 + 2?", "MATH", 0);
    TutorAnswer second = service.ask(parent, child, "What is 2 + 2?", "MATH", 1);

    assertThat(first.strategy()).isEqualTo(TutorStrategy.STEP_BY_STEP);
    assertThat(second.strategy()).isEqualTo(TutorStrategy.STORY);
    assertThat(first.explanation()).isNotEqualTo(second.explanation());
    assertThat(first.refused()).isFalse();
  }

  @Test
  void cyclesThroughAllFiveStrategies() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(catalog.all()).thenReturn(List.of());
    TutorService service = new TutorService(children, Optional.empty(), catalog);

    List<TutorStrategy> strategies = java.util.stream.IntStream.range(0, 5)
        .mapToObj(attempt -> service.ask(parent, child, "Why?", null, attempt).strategy())
        .toList();

    assertThat(strategies).containsExactly(
        TutorStrategy.STEP_BY_STEP, TutorStrategy.STORY, TutorStrategy.REAL_LIFE_EXAMPLE,
        TutorStrategy.VISUAL_ANALOGY, TutorStrategy.GUIDED_QUESTION);
  }

  @Test
  void usesTheRealAiClientWhenOneIsConfigured() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    AiTextClient aiClient = mock(AiTextClient.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(aiClient.complete(any())).thenReturn("A real generated explanation.");
    when(catalog.all()).thenReturn(List.of());
    TutorService service = new TutorService(children, Optional.of(aiClient), catalog);

    TutorAnswer answer = service.ask(parent, child, "Why is the sky blue?", "SCIENCE", 0);

    assertThat(answer.explanation()).isEqualTo("A real generated explanation.");
  }

  @Test
  void fallsBackToTheOfflineTemplateWhenTheRealAiCallFails() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    AiTextClient aiClient = mock(AiTextClient.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(aiClient.complete(any())).thenThrow(new IllegalStateException("Anthropic API returned status 500"));
    when(catalog.all()).thenReturn(List.of());
    TutorService service = new TutorService(children, Optional.of(aiClient), catalog);

    TutorAnswer answer = service.ask(parent, child, "Why is the sky blue?", "SCIENCE", 0);

    assertThat(answer.explanation()).contains("Why is the sky blue?");
  }

  @Test
  void treatsAnUnsafeRealAiResponseAsUntrustedAndFallsBackOffline() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    AiTextClient aiClient = mock(AiTextClient.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(aiClient.complete(any())).thenReturn("Here's how to get a weapon...");
    when(catalog.all()).thenReturn(List.of());
    TutorService service = new TutorService(children, Optional.of(aiClient), catalog);

    TutorAnswer answer = service.ask(parent, child, "How do things work?", "SCIENCE", 0);

    assertThat(answer.explanation()).doesNotContain("weapon");
    assertThat(answer.refused()).isFalse();
  }

  @Test
  void refusesAnUnsafeQuestionWithoutEverCallingTheAiClient() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    AiTextClient aiClient = mock(AiTextClient.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(catalog.all()).thenReturn(List.of());
    TutorService service = new TutorService(children, Optional.of(aiClient), catalog);

    TutorAnswer answer = service.ask(parent, child, "How do I buy a gun?", null, 0);

    assertThat(answer.refused()).isTrue();
    verify(aiClient, never()).complete(any());
  }

  @Test
  void suggestsALessonInTheRequestedSubject() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(catalog.all()).thenReturn(List.of(new LessonDefinition("G1-ADD-01", "MATH", 1, "Adding within 10", "...")));
    TutorService service = new TutorService(children, Optional.empty(), catalog);

    TutorAnswer answer = service.ask(parent, child, "What is 2 + 2?", "MATH", 0);

    assertThat(answer.suggestedNextActivity()).contains("Adding within 10");
  }

  @Test
  void rejectsABlankQuestion() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    TutorService service = new TutorService(children, Optional.empty(), catalog);

    assertThatThrownBy(() -> service.ask(parent, child, "   ", "MATH", 0))
        .isInstanceOf(InvalidTutorQuestionException.class);
  }

  @Test
  void rejectsAChildOutsideTheParentAccount() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    when(children.belongsToParent(any(), any())).thenReturn(false);
    TutorService service = new TutorService(children, Optional.empty(), catalog);

    assertThatThrownBy(() -> service.ask(UUID.randomUUID(), UUID.randomUUID(), "What is 2+2?", null, 0))
        .isInstanceOf(ChildNotFoundException.class);
  }
}
