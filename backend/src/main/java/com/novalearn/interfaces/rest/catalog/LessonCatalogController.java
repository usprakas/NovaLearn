package com.novalearn.interfaces.rest.catalog;

import com.novalearn.application.catalog.LessonCatalogService;
import com.novalearn.domain.catalog.Exercise;
import com.novalearn.domain.catalog.LessonDefinition;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/lessons")
@Tag(name = "Lesson catalog")
public class LessonCatalogController {

  private final LessonCatalogService catalog;

  public LessonCatalogController(LessonCatalogService catalog) {
    this.catalog = catalog;
  }

  @GetMapping
  public List<LessonSummaryResponse> list() {
    return catalog.all().stream().map(LessonSummaryResponse::from).toList();
  }

  @GetMapping("/{code}")
  public LessonResponse get(@PathVariable String code) {
    LessonDefinition lesson = catalog.get(code);
    List<Exercise> exercises = catalog.exercisesOf(code);
    return LessonResponse.from(lesson, exercises);
  }

  public record LessonSummaryResponse(String code, String subject, int order, String title, String description) {
    static LessonSummaryResponse from(LessonDefinition lesson) {
      return new LessonSummaryResponse(lesson.code(), lesson.subject(), lesson.order(), lesson.title(), lesson.description());
    }
  }

  /** {@code exercises} deliberately carries no answer-index field — see {@code Exercise}'s Javadoc. */
  public record LessonResponse(String code, String subject, String title, String description, List<ExerciseResponse> exercises) {
    static LessonResponse from(LessonDefinition lesson, List<Exercise> exercises) {
      return new LessonResponse(lesson.code(), lesson.subject(), lesson.title(), lesson.description(),
          exercises.stream().map(ExerciseResponse::from).toList());
    }
  }

  public record ExerciseResponse(UUID id, int order, String prompt, List<String> choices) {
    static ExerciseResponse from(Exercise exercise) {
      return new ExerciseResponse(exercise.id(), exercise.order(), exercise.prompt(), exercise.choices());
    }
  }
}
