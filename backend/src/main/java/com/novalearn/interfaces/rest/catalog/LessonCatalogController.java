package com.novalearn.interfaces.rest.catalog;

import com.novalearn.application.catalog.LessonCatalog;
import com.novalearn.application.catalog.LessonNotFoundException;
import com.novalearn.domain.catalog.LessonDefinition;
import com.novalearn.domain.catalog.LessonQuestion;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/lessons")
@Tag(name = "Lesson catalog")
public class LessonCatalogController {

  private final LessonCatalog catalog;

  public LessonCatalogController(LessonCatalog catalog) {
    this.catalog = catalog;
  }

  @GetMapping
  public List<LessonSummaryResponse> list() {
    return catalog.all().stream().map(LessonSummaryResponse::from).toList();
  }

  @GetMapping("/{code}")
  public LessonResponse get(@PathVariable String code) {
    LessonDefinition lesson = catalog.find(code).orElseThrow(LessonNotFoundException::new);
    return LessonResponse.from(lesson);
  }

  public record LessonSummaryResponse(String code, String subject, int order, String title, String description) {
    static LessonSummaryResponse from(LessonDefinition lesson) {
      return new LessonSummaryResponse(lesson.code(), lesson.subject(), lesson.order(), lesson.title(), lesson.description());
    }
  }

  public record LessonResponse(
      String code, String subject, String title, String description, List<QuestionResponse> questions) {
    static LessonResponse from(LessonDefinition lesson) {
      return new LessonResponse(lesson.code(), lesson.subject(), lesson.title(), lesson.description(),
          lesson.questions().stream().map(QuestionResponse::from).toList());
    }
  }

  public record QuestionResponse(String prompt, List<String> choices, int answerIndex) {
    static QuestionResponse from(LessonQuestion question) {
      return new QuestionResponse(question.prompt(), question.choices(), question.answerIndex());
    }
  }
}
