package com.novalearn.application.catalog;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.novalearn.domain.catalog.Exercise;
import com.novalearn.domain.catalog.LessonDefinition;
import com.novalearn.domain.child.GradeLevel;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class LessonCatalogServiceTest {

  @Test
  void listsLessonsSortedBySubjectThenOrder() {
    LessonRepository lessons = mock(LessonRepository.class);
    ExerciseRepository exercises = mock(ExerciseRepository.class);
    when(lessons.findAll()).thenReturn(List.of(
        new LessonDefinition("G1-SUB-01", "MATH", GradeLevel.GRADE_1, 3, "Subtracting within 10", "..."),
        new LessonDefinition("G1-ADD-01", "MATH", GradeLevel.GRADE_1, 2, "Adding within 10", "...")));
    LessonCatalogService service = new LessonCatalogService(lessons, exercises);

    List<LessonDefinition> all = service.all();

    assertThat(all).extracting(LessonDefinition::code).containsExactly("G1-ADD-01", "G1-SUB-01");
  }

  @Test
  void filtersLessonsByGradeLevel() {
    LessonRepository lessons = mock(LessonRepository.class);
    ExerciseRepository exercises = mock(ExerciseRepository.class);
    LessonDefinition grade2Lesson =
        new LessonDefinition("G2-ADD-01", "MATH", GradeLevel.GRADE_2, 1, "Adding within 100", "...");
    when(lessons.findByGradeLevel(GradeLevel.GRADE_2)).thenReturn(List.of(grade2Lesson));
    LessonCatalogService service = new LessonCatalogService(lessons, exercises);

    assertThat(service.forGrade(GradeLevel.GRADE_2)).containsExactly(grade2Lesson);
  }

  @Test
  void getsALessonByCode() {
    LessonRepository lessons = mock(LessonRepository.class);
    ExerciseRepository exercises = mock(ExerciseRepository.class);
    LessonDefinition lesson =
        new LessonDefinition("G1-ADD-01", "MATH", GradeLevel.GRADE_1, 2, "Adding within 10", "...");
    when(lessons.findByCode("G1-ADD-01")).thenReturn(Optional.of(lesson));
    LessonCatalogService service = new LessonCatalogService(lessons, exercises);

    assertThat(service.get("G1-ADD-01")).isEqualTo(lesson);
  }

  @Test
  void throwsLessonNotFoundForAnUnknownCode() {
    LessonRepository lessons = mock(LessonRepository.class);
    ExerciseRepository exercises = mock(ExerciseRepository.class);
    when(lessons.findByCode("NOPE")).thenReturn(Optional.empty());
    LessonCatalogService service = new LessonCatalogService(lessons, exercises);

    assertThatThrownBy(() -> service.get("NOPE")).isInstanceOf(LessonNotFoundException.class);
  }

  @Test
  void exposesExercisesForALessonWithoutAnAnswerIndex() {
    LessonRepository lessons = mock(LessonRepository.class);
    ExerciseRepository exercises = mock(ExerciseRepository.class);
    Exercise exercise = new Exercise(UUID.randomUUID(), "G1-ADD-01", "ADDITION", 1, "What is 2 + 2?", List.of("3", "4", "5"));
    when(exercises.findByLessonCode("G1-ADD-01")).thenReturn(List.of(exercise));
    LessonCatalogService service = new LessonCatalogService(lessons, exercises);

    assertThat(service.exercisesOf("G1-ADD-01")).containsExactly(exercise);
  }

  @Test
  void reportsTheSubjectForAKnownLessonCode() {
    LessonRepository lessons = mock(LessonRepository.class);
    ExerciseRepository exercises = mock(ExerciseRepository.class);
    when(lessons.findByCode("G1-ADD-01"))
        .thenReturn(Optional.of(new LessonDefinition("G1-ADD-01", "MATH", GradeLevel.GRADE_1, 2, "t", "d")));
    LessonCatalogService service = new LessonCatalogService(lessons, exercises);

    assertThat(service.subjectOf("G1-ADD-01")).contains("MATH");
    assertThat(service.subjectOf("NOT-A-REAL-CODE")).isEmpty();
  }
}
