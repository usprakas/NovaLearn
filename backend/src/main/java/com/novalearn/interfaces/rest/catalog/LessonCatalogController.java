package com.novalearn.interfaces.rest.catalog;

import com.novalearn.application.catalog.LessonCatalogService;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.application.progress.LessonSetService;
import com.novalearn.domain.catalog.Exercise;
import com.novalearn.domain.catalog.LessonDefinition;
import com.novalearn.domain.child.ChildProfile;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Lesson listing is child-scoped (not just parent-scoped) because it must be filtered to the
 * child's own grade level — a kindergartner should never see a Grade 6 lesson in their list, and
 * vice versa. Lesson detail stays ungated by grade: a child only ever reaches a detail page via a
 * code from their own already-filtered list, so there is no real exposure in leaving it open.
 */
@RestController
@Tag(name = "Lesson catalog")
public class LessonCatalogController {

  private final LessonCatalogService catalog;
  private final ChildProfileRepository children;
  private final LessonSetService sets;

  public LessonCatalogController(LessonCatalogService catalog, ChildProfileRepository children, LessonSetService sets) {
    this.catalog = catalog;
    this.children = children;
    this.sets = sets;
  }

  @GetMapping("/api/v1/children/{childId}/lessons")
  public List<LessonSummaryResponse> list(@AuthenticationPrincipal UUID parentId, @PathVariable UUID childId) {
    ChildProfile child = children.findById(childId)
        .filter(c -> c.parentId().equals(parentId))
        .orElseThrow(ChildNotFoundException::new);
    return catalog.forGrade(child.gradeLevel()).stream().map(LessonSummaryResponse::from).toList();
  }

  @GetMapping("/api/v1/lessons/{code}")
  public LessonResponse get(@PathVariable String code) {
    LessonDefinition lesson = catalog.get(code);
    List<Exercise> exercises = catalog.exercisesOf(code);
    return LessonResponse.from(lesson, exercises);
  }

  /** One set of a lesson's questions; omit {@code number} to get the child's next unfinished set. */
  @GetMapping("/api/v1/children/{childId}/lessons/{code}/set")
  public LessonSetResponse set(
      @AuthenticationPrincipal UUID parentId,
      @PathVariable UUID childId,
      @PathVariable String code,
      @RequestParam(required = false) Integer number) {
    return LessonSetResponse.from(sets.set(parentId, childId, code, number));
  }

  public record LessonSummaryResponse(
      String code, String subject, String gradeLevel, int order, String title, String description) {
    static LessonSummaryResponse from(LessonDefinition lesson) {
      return new LessonSummaryResponse(lesson.code(), lesson.subject(), lesson.gradeLevel().name(), lesson.order(),
          lesson.title(), lesson.description());
    }
  }

  public record LessonResponse(String code, String subject, String title, String description, List<ExerciseResponse> exercises) {
    static LessonResponse from(LessonDefinition lesson, List<Exercise> exercises) {
      return new LessonResponse(lesson.code(), lesson.subject(), lesson.title(), lesson.description(),
          exercises.stream().map(ExerciseResponse::from).toList());
    }
  }

  public record LessonSetResponse(
      String code, String subject, String title, String description,
      int setNumber, int totalSets, boolean completedAllSets, List<ExerciseResponse> exercises) {
    static LessonSetResponse from(LessonSetService.LessonSet set) {
      LessonDefinition lesson = set.lesson();
      return new LessonSetResponse(lesson.code(), lesson.subject(), lesson.title(), lesson.description(),
          set.setNumber(), set.totalSets(), set.completedAllSets(),
          set.exercises().stream().map(ExerciseResponse::from).toList());
    }
  }

  public record ExerciseResponse(UUID id, int order, String prompt, List<String> choices) {
    static ExerciseResponse from(Exercise exercise) {
      return new ExerciseResponse(exercise.id(), exercise.order(), exercise.prompt(), exercise.choices());
    }
  }
}
