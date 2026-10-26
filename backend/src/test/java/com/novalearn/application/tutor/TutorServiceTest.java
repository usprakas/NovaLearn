package com.novalearn.application.tutor;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.novalearn.application.ai.AiTextClient;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.tutor.TutorAnswer;
import com.novalearn.domain.tutor.TutorStrategy;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class TutorServiceTest {

  @Test
  void answersOfflineWithAnIncreasinglyDifferentStrategyOnEachAttempt() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    TutorService service = new TutorService(children, Optional.empty());

    TutorAnswer first = service.ask(parent, child, "What is 2 + 2?", "MATH", 0);
    TutorAnswer second = service.ask(parent, child, "What is 2 + 2?", "MATH", 1);

    assertThat(first.strategy()).isEqualTo(TutorStrategy.STEP_BY_STEP);
    assertThat(second.strategy()).isEqualTo(TutorStrategy.STORY);
    assertThat(first.explanation()).isNotEqualTo(second.explanation());
  }

  @Test
  void usesTheRealAiClientWhenOneIsConfigured() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    AiTextClient aiClient = mock(AiTextClient.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(aiClient.complete(any())).thenReturn("A real generated explanation.");
    TutorService service = new TutorService(children, Optional.of(aiClient));

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
    TutorService service = new TutorService(children, Optional.of(aiClient));

    TutorAnswer answer = service.ask(parent, child, "Why is the sky blue?", "SCIENCE", 0);

    assertThat(answer.explanation()).contains("Why is the sky blue?");
  }

  @Test
  void rejectsABlankQuestion() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    TutorService service = new TutorService(children, Optional.empty());

    assertThatThrownBy(() -> service.ask(parent, child, "   ", "MATH", 0))
        .isInstanceOf(InvalidTutorQuestionException.class);
  }

  @Test
  void rejectsAChildOutsideTheParentAccount() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    when(children.belongsToParent(any(), any())).thenReturn(false);
    TutorService service = new TutorService(children, Optional.empty());

    assertThatThrownBy(() -> service.ask(UUID.randomUUID(), UUID.randomUUID(), "What is 2+2?", null, 0))
        .isInstanceOf(ChildNotFoundException.class);
  }
}
