package com.novalearn.application.progress;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.novalearn.application.catalog.ExerciseAnswerKey;
import com.novalearn.application.catalog.ExerciseRepository;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.catalog.Exercise;
import com.novalearn.domain.progress.ExerciseEvaluation;
import com.novalearn.domain.progress.SkillProgress;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class ExerciseEvaluationServiceTest {

  private final ChildProfileRepository children = mock(ChildProfileRepository.class);
  private final ExerciseRepository exercises = mock(ExerciseRepository.class);
  private final ExerciseAttemptRepository attempts = mock(ExerciseAttemptRepository.class);
  private final SkillProgressRepository skillProgress = mock(SkillProgressRepository.class);
  private final ProgressService progressService = mock(ProgressService.class);
  private final ExerciseEvaluationService service =
      new ExerciseEvaluationService(children, exercises, attempts, skillProgress, progressService);

  @Test
  void marksACorrectAnswerCorrectAndNeverReturnsAHint() {
    UUID parentId = UUID.randomUUID();
    UUID childId = UUID.randomUUID();
    UUID exerciseId = UUID.randomUUID();
    when(children.belongsToParent(childId, parentId)).thenReturn(true);
    when(exercises.findById(exerciseId)).thenReturn(Optional.of(
        new Exercise(exerciseId, "G1-ADD-01", "ADDITION", 1, "What is 2 + 2?", List.of("3", "4", "5"))));
    when(exercises.findAnswerKey(exerciseId)).thenReturn(Optional.of(new ExerciseAnswerKey("ADDITION", 1, "2 + 2 = 4.", "Count up from 2.")));
    when(skillProgress.findByChildIdAndSkillCode(childId, "ADDITION")).thenReturn(Optional.empty());
    when(skillProgress.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    ExerciseEvaluation evaluation = service.submitAnswer(parentId, childId, exerciseId, 1);

    assertThat(evaluation.correct()).isTrue();
    assertThat(evaluation.explanation()).isEqualTo("2 + 2 = 4.");
    assertThat(evaluation.hint()).isNull();
    verify(progressService).recalculate(childId, "G1-ADD-01");
  }

  @Test
  void marksAnIncorrectAnswerIncorrectAndReturnsAHint() {
    UUID parentId = UUID.randomUUID();
    UUID childId = UUID.randomUUID();
    UUID exerciseId = UUID.randomUUID();
    when(children.belongsToParent(childId, parentId)).thenReturn(true);
    when(exercises.findById(exerciseId)).thenReturn(Optional.of(
        new Exercise(exerciseId, "G1-ADD-01", "ADDITION", 1, "What is 2 + 2?", List.of("3", "4", "5"))));
    when(exercises.findAnswerKey(exerciseId)).thenReturn(Optional.of(new ExerciseAnswerKey("ADDITION", 1, "2 + 2 = 4.", "Count up from 2.")));
    when(skillProgress.findByChildIdAndSkillCode(childId, "ADDITION")).thenReturn(Optional.empty());
    when(skillProgress.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    ExerciseEvaluation evaluation = service.submitAnswer(parentId, childId, exerciseId, 0);

    assertThat(evaluation.correct()).isFalse();
    assertThat(evaluation.hint()).isEqualTo("Count up from 2.");
  }

  @Test
  void accumulatesSkillProgressAcrossAttempts() {
    UUID parentId = UUID.randomUUID();
    UUID childId = UUID.randomUUID();
    UUID exerciseId = UUID.randomUUID();
    when(children.belongsToParent(childId, parentId)).thenReturn(true);
    when(exercises.findById(exerciseId)).thenReturn(Optional.of(
        new Exercise(exerciseId, "G1-ADD-01", "ADDITION", 1, "What is 2 + 2?", List.of("3", "4", "5"))));
    when(exercises.findAnswerKey(exerciseId)).thenReturn(Optional.of(new ExerciseAnswerKey("ADDITION", 1, "2 + 2 = 4.", "hint")));
    when(skillProgress.findByChildIdAndSkillCode(childId, "ADDITION"))
        .thenReturn(Optional.of(new SkillProgress(childId, "ADDITION", 2, 1, null)));
    when(skillProgress.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    service.submitAnswer(parentId, childId, exerciseId, 1);

    verify(skillProgress).save(org.mockito.ArgumentMatchers.argThat(saved -> saved.attemptsCount() == 3 && saved.correctCount() == 2));
  }

  @Test
  void rejectsAnUnknownExercise() {
    UUID parentId = UUID.randomUUID();
    UUID childId = UUID.randomUUID();
    UUID exerciseId = UUID.randomUUID();
    when(children.belongsToParent(childId, parentId)).thenReturn(true);
    when(exercises.findById(exerciseId)).thenReturn(Optional.empty());

    assertThatThrownBy(() -> service.submitAnswer(parentId, childId, exerciseId, 0)).isInstanceOf(ExerciseNotFoundException.class);
  }

  @Test
  void rejectsAChildOutsideTheParentAccount() {
    when(children.belongsToParent(any(), any())).thenReturn(false);

    assertThatThrownBy(() -> service.submitAnswer(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID(), 0))
        .isInstanceOf(ChildNotFoundException.class);
  }
}
