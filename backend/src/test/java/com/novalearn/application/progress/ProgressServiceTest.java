package com.novalearn.application.progress;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.novalearn.application.catalog.ExerciseRepository;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.application.rewards.RewardsService;
import com.novalearn.domain.catalog.Exercise;
import com.novalearn.domain.progress.LessonProgress;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class ProgressServiceTest {

  private final LessonProgressRepository progress = mock(LessonProgressRepository.class);
  private final ChildProfileRepository children = mock(ChildProfileRepository.class);
  private final ExerciseRepository exercises = mock(ExerciseRepository.class);
  private final ExerciseAttemptRepository attempts = mock(ExerciseAttemptRepository.class);
  private final RewardsService rewards = mock(RewardsService.class);
  private final ProgressService service = new ProgressService(progress, children, exercises, attempts, rewards);

  private List<Exercise> threeExercises(String lessonCode) {
    return List.of(
        new Exercise(UUID.randomUUID(), lessonCode, "ADDITION", 1, "p1", List.of("a", "b")),
        new Exercise(UUID.randomUUID(), lessonCode, "ADDITION", 2, "p2", List.of("a", "b")),
        new Exercise(UUID.randomUUID(), lessonCode, "ADDITION", 3, "p3", List.of("a", "b")));
  }

  @Test
  void marksALessonCompleteOnceEveryExerciseHasBeenAttemptedAndAwardsCoinsExactlyOnce() {
    UUID childId = UUID.randomUUID();
    List<Exercise> lessonExercises = threeExercises("G1-ADD-01");
    when(exercises.findByLessonCode("G1-ADD-01")).thenReturn(lessonExercises);
    Set<UUID> exerciseIds = lessonExercises.stream().map(Exercise::id).collect(java.util.stream.Collectors.toSet());
    when(attempts.findAttemptedExerciseIds(childId, exerciseIds)).thenReturn(exerciseIds);
    when(attempts.countCorrectAmong(childId, exerciseIds)).thenReturn(2L);
    when(progress.findByChildIdAndLessonCode(childId, "G1-ADD-01")).thenReturn(Optional.empty());
    when(progress.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    LessonProgress result = service.recalculate(childId, "G1-ADD-01");

    assertThat(result.completed()).isTrue();
    assertThat(result.score()).isEqualTo(67);
    verify(rewards).award(childId, 10, "Completed a lesson", "LESSON_COMPLETION", result.id().toString());
  }

  @Test
  void doesNotMarkALessonCompleteUntilEveryExerciseHasBeenAttempted() {
    UUID childId = UUID.randomUUID();
    List<Exercise> lessonExercises = threeExercises("G1-ADD-01");
    when(exercises.findByLessonCode("G1-ADD-01")).thenReturn(lessonExercises);
    Set<UUID> exerciseIds = lessonExercises.stream().map(Exercise::id).collect(java.util.stream.Collectors.toSet());
    Set<UUID> attemptedOnly = Set.of(lessonExercises.get(0).id(), lessonExercises.get(1).id());
    when(attempts.findAttemptedExerciseIds(childId, exerciseIds)).thenReturn(attemptedOnly);
    when(attempts.countCorrectAmong(childId, exerciseIds)).thenReturn(1L);
    when(progress.findByChildIdAndLessonCode(childId, "G1-ADD-01")).thenReturn(Optional.empty());
    when(progress.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    LessonProgress result = service.recalculate(childId, "G1-ADD-01");

    assertThat(result.completed()).isFalse();
    verify(rewards, never()).award(any(), anyInt(), anyString(), anyString(), anyString());
  }

  @Test
  void doesNotAwardTwiceWhenRecalculatedAfterAlreadyCompleted() {
    UUID childId = UUID.randomUUID();
    List<Exercise> lessonExercises = threeExercises("G1-ADD-01");
    when(exercises.findByLessonCode("G1-ADD-01")).thenReturn(lessonExercises);
    Set<UUID> exerciseIds = lessonExercises.stream().map(Exercise::id).collect(java.util.stream.Collectors.toSet());
    when(attempts.findAttemptedExerciseIds(childId, exerciseIds)).thenReturn(exerciseIds);
    when(attempts.countCorrectAmong(childId, exerciseIds)).thenReturn(3L);
    UUID progressId = UUID.randomUUID();
    when(progress.findByChildIdAndLessonCode(childId, "G1-ADD-01"))
        .thenReturn(Optional.of(new LessonProgress(progressId, childId, "G1-ADD-01", 100, true, Instant.now())));
    when(progress.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    service.recalculate(childId, "G1-ADD-01");

    verify(rewards, never()).award(any(), anyInt(), anyString(), anyString(), anyString());
  }

  @Test
  void rejectsAChildOutsideTheParentAccount() {
    when(children.belongsToParent(any(), any())).thenReturn(false);

    assertThatThrownBy(() -> service.list(UUID.randomUUID(), UUID.randomUUID())).isInstanceOf(ChildNotFoundException.class);
  }
}
