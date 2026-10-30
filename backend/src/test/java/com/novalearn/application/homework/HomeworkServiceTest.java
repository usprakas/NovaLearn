package com.novalearn.application.homework;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.novalearn.application.ai.AiTextClient;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.child.ChildProfile;
import com.novalearn.domain.child.GradeLevel;
import com.novalearn.domain.homework.HomeworkGuidance;
import com.novalearn.domain.homework.HomeworkGuidance.WorkedStep;
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

  private HomeworkService serviceAnswering(String aiResponse) {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    AiTextClient aiClient = mock(AiTextClient.class);
    when(children.belongsToParent(any(), any())).thenReturn(true);
    when(aiClient.complete(any())).thenReturn(aiResponse);
    return new HomeworkService(children, Optional.of(aiClient));
  }

  @Test
  void parsesAWorkedSolutionWithMathAndAFinalAnswer() {
    HomeworkGuidance guidance = serviceAnswering("""
        STEP: The flat fee is paid every month, so it starts our equation. | C = 12 + ...
        STEP: Each movie costs $3, so m movies cost 3 x m. | C = 12 + 3m
        STEP: Put in 5 movies for m and multiply first. | C = 12 + 3 x 5 = 12 + 15 = 27
        ANSWER: $27
        TIP: You turned a word problem into an equation!
        """).explain(UUID.randomUUID(), UUID.randomUUID(), "Streaming costs $12 plus $3 per movie...");

    assertThat(guidance.workedSteps()).hasSize(3);
    assertThat(guidance.workedSteps().get(2))
        .isEqualTo(new WorkedStep("Put in 5 movies for m and multiply first.", "C = 12 + 3 x 5 = 12 + 15 = 27"));
    assertThat(guidance.finalAnswer()).isEqualTo("$27");
    // Older clients only read steps/finalHint, so those still carry the work and the answer.
    assertThat(guidance.steps().get(1)).contains("C = 12 + 3m");
    assertThat(guidance.finalHint()).startsWith("Answer: $27.");
  }

  @Test
  void toleratesNumberedStepsAndKeepsAbsoluteValueBarsInTheMath() {
    HomeworkGuidance guidance = serviceAnswering("""
        1. STEP: Distance from zero is the absolute value. | |-4| = 4
        2) Step 2: Add the distances. | 4 + 3 = 7
        Final Answer: 7
        """).explain(UUID.randomUUID(), UUID.randomUUID(), "What is |-4| + |3|?");

    assertThat(guidance.workedSteps()).extracting(WorkedStep::work).containsExactly("|-4| = 4", "4 + 3 = 7");
    assertThat(guidance.finalAnswer()).isEqualTo("7");
  }

  @Test
  void stripsTheModelsOwnNumberingWhenItIgnoresTheFormat() {
    HomeworkGuidance guidance = serviceAnswering("1. Find the flat fee.\n2. Add the movie cost.\nYou can do it!")
        .explain(UUID.randomUUID(), UUID.randomUUID(), "question");

    assertThat(guidance.steps()).containsExactly("Find the flat fee.", "Add the movie cost.");
    assertThat(guidance.workedSteps()).isEmpty();
    assertThat(guidance.finalAnswer()).isNull();
  }

  @Test
  void pitchesTheExplanationAtTheChildsGrade() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    AiTextClient aiClient = mock(AiTextClient.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    ChildProfile profile = mock(ChildProfile.class);
    when(profile.gradeLevel()).thenReturn(GradeLevel.GRADE_3);
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(children.findById(child)).thenReturn(Optional.of(profile));
    when(aiClient.complete(any())).thenReturn("STEP: Add. | 2 + 2 = 4\nANSWER: 4");

    new HomeworkService(children, Optional.of(aiClient)).explain(parent, child, "What is 2 + 2?");

    verify(aiClient).complete(contains("a Grade 3 student"));
  }

  @Test
  void offlineFallbackNeverClaimsAnAnswer() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    when(children.belongsToParent(any(), any())).thenReturn(true);

    HomeworkGuidance guidance = new HomeworkService(children, Optional.empty())
        .explain(UUID.randomUUID(), UUID.randomUUID(), "What is 7 + 5?");

    assertThat(guidance.workedSteps()).isEmpty();
    assertThat(guidance.finalAnswer()).isNull();
  }
}
