package com.novalearn.application.progress;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.novalearn.application.catalog.ExerciseRepository;
import com.novalearn.application.catalog.LessonRepository;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.catalog.Exercise;
import com.novalearn.domain.catalog.LessonDefinition;
import com.novalearn.domain.child.GradeLevel;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.IntStream;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class LessonSetServiceTest {

  private final UUID parent = UUID.randomUUID();
  private final UUID child = UUID.randomUUID();
  private final ChildProfileRepository children = mock(ChildProfileRepository.class);
  private final LessonRepository lessons = mock(LessonRepository.class);
  private final ExerciseRepository exercises = mock(ExerciseRepository.class);
  private final ExerciseAttemptRepository attempts = mock(ExerciseAttemptRepository.class);
  private final LessonSetService service = new LessonSetService(children, lessons, exercises, attempts);
  // Seven questions, returned out of order: sets are [1,2,3], [4,5,6], [7].
  private final List<Exercise> lessonExercises = IntStream.of(5, 1, 7, 3, 2, 6, 4)
      .mapToObj(i -> new Exercise(UUID.randomUUID(), "L", "S", i, "Q" + i, List.of("a", "b", "c")))
      .toList();

  @BeforeEach
  void setUp() {
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(lessons.findByCode("L")).thenReturn(Optional.of(new LessonDefinition("L", "MATH", GradeLevel.GRADE_1, 1, "T", "D")));
    when(exercises.findByLessonCode("L")).thenReturn(lessonExercises);
  }

  private void attempted(int... orders) {
    Set<UUID> ids = new java.util.HashSet<>();
    for (int o : orders) {
      lessonExercises.stream().filter(e -> e.order() == o).forEach(e -> ids.add(e.id()));
    }
    when(attempts.findAttemptedExerciseIds(eq(child), any())).thenReturn(ids);
  }

  @Test
  void aNewChildStartsAtTheFirstSetInOrder() {
    attempted();
    LessonSetService.LessonSet set = service.set(parent, child, "L", null);
    assertThat(set.setNumber()).isEqualTo(1);
    assertThat(set.totalSets()).isEqualTo(3);
    assertThat(set.completedAllSets()).isFalse();
    assertThat(set.exercises()).extracting(Exercise::order).containsExactly(1, 2, 3);
  }

  @Test
  void finishingASetMovesTheChildOnToTheNextOne() {
    attempted(1, 2, 3);
    LessonSetService.LessonSet set = service.set(parent, child, "L", null);
    assertThat(set.setNumber()).isEqualTo(2);
    assertThat(set.exercises()).extracting(Exercise::order).containsExactly(4, 5, 6);
  }

  @Test
  void aPartlyAnsweredSetIsResumedNotSkipped() {
    attempted(1, 2, 3, 4);
    assertThat(service.set(parent, child, "L", null).setNumber()).isEqualTo(2);
  }

  @Test
  void theLastSetCanBeShorter() {
    attempted(1, 2, 3, 4, 5, 6);
    LessonSetService.LessonSet set = service.set(parent, child, "L", null);
    assertThat(set.setNumber()).isEqualTo(3);
    assertThat(set.exercises()).extracting(Exercise::order).containsExactly(7);
  }

  @Test
  void afterEverySetItStartsOverForPracticeAndSaysSo() {
    attempted(1, 2, 3, 4, 5, 6, 7);
    LessonSetService.LessonSet set = service.set(parent, child, "L", null);
    assertThat(set.setNumber()).isEqualTo(1);
    assertThat(set.completedAllSets()).isTrue();
  }

  @Test
  void aRequestedSetNumberIsServedAndClamped() {
    attempted();
    assertThat(service.set(parent, child, "L", 2).exercises()).extracting(Exercise::order).containsExactly(4, 5, 6);
    assertThat(service.set(parent, child, "L", 99).setNumber()).isEqualTo(3);
    assertThat(service.set(parent, child, "L", 0).setNumber()).isEqualTo(1);
  }

  @Test
  void refusesAnotherParentsChild() {
    assertThatThrownBy(() -> service.set(UUID.randomUUID(), child, "L", null)).isInstanceOf(ChildNotFoundException.class);
  }
}
