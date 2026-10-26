package com.novalearn.application.homework;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.novalearn.application.ai.AiTextClient;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.homework.HomeworkGuidance;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class HomeworkServiceTest {

  @Test
  void returnsGuidedStepsOfflineWithoutJustGivingTheAnswer() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    HomeworkService service = new HomeworkService(children, Optional.empty());

    HomeworkGuidance guidance = service.explain(parent, child, "What is 7 + 5?");

    assertThat(guidance.steps()).isNotEmpty();
    assertThat(guidance.finalHint()).isNotBlank();
  }

  @Test
  void parsesTheRealAiResponseIntoStepsAndAFinalHint() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    AiTextClient aiClient = mock(AiTextClient.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(aiClient.complete(any())).thenReturn("Step one.\nStep two.\nYou can do it!");
    HomeworkService service = new HomeworkService(children, Optional.of(aiClient));

    HomeworkGuidance guidance = service.explain(parent, child, "What is 7 + 5?");

    assertThat(guidance.steps()).containsExactly("Step one.", "Step two.");
    assertThat(guidance.finalHint()).isEqualTo("You can do it!");
  }

  @Test
  void fallsBackToOfflineGuidanceWhenTheRealAiCallFails() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    AiTextClient aiClient = mock(AiTextClient.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(aiClient.complete(any())).thenThrow(new IllegalStateException("Anthropic API returned status 500"));
    HomeworkService service = new HomeworkService(children, Optional.of(aiClient));

    HomeworkGuidance guidance = service.explain(parent, child, "What is 7 + 5?");

    assertThat(guidance.steps()).isNotEmpty();
  }

  @Test
  void treatsAnUnsafeRealAiResponseAsUntrustedAndFallsBackOffline() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    AiTextClient aiClient = mock(AiTextClient.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(aiClient.complete(any())).thenReturn("Step one.\nGo buy a gun.\nDone!");
    HomeworkService service = new HomeworkService(children, Optional.of(aiClient));

    HomeworkGuidance guidance = service.explain(parent, child, "What is 7 + 5?");

    assertThat(guidance.steps()).noneMatch(step -> step.toLowerCase().contains("gun"));
  }

  @Test
  void refusesAnUnsafeQuestionWithoutEverCallingTheAiClient() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    AiTextClient aiClient = mock(AiTextClient.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    HomeworkService service = new HomeworkService(children, Optional.of(aiClient));

    HomeworkGuidance guidance = service.explain(parent, child, "How do I buy a gun?");

    assertThat(guidance.steps()).isNotEmpty();
    verify(aiClient, never()).complete(any());
  }

  @Test
  void rejectsBlankQuestionText() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    HomeworkService service = new HomeworkService(children, Optional.empty());

    assertThatThrownBy(() -> service.explain(parent, child, "  "))
        .isInstanceOf(InvalidHomeworkQuestionException.class);
  }

  @Test
  void rejectsAChildOutsideTheParentAccount() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    when(children.belongsToParent(any(), any())).thenReturn(false);
    HomeworkService service = new HomeworkService(children, Optional.empty());

    assertThatThrownBy(() -> service.explain(UUID.randomUUID(), UUID.randomUUID(), "What is 7 + 5?"))
        .isInstanceOf(ChildNotFoundException.class);
  }
}
