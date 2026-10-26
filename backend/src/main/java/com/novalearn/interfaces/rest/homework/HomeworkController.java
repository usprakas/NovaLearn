package com.novalearn.interfaces.rest.homework;

import com.novalearn.application.homework.HomeworkService;
import com.novalearn.domain.homework.HomeworkGuidance;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/children/{childId}/homework")
@Tag(name = "Homework helper")
public class HomeworkController {

  private final HomeworkService homework;

  public HomeworkController(HomeworkService homework) {
    this.homework = homework;
  }

  @PostMapping("/questions")
  @ResponseStatus(HttpStatus.CREATED)
  public HomeworkGuidanceResponse explain(
      @AuthenticationPrincipal UUID parentId,
      @PathVariable UUID childId,
      @RequestBody @Valid ExplainHomeworkRequest request) {
    return HomeworkGuidanceResponse.from(homework.explain(parentId, childId, request.questionText()));
  }

  public record ExplainHomeworkRequest(@NotBlank String questionText) { }

  public record HomeworkGuidanceResponse(List<String> steps, String finalHint) {
    static HomeworkGuidanceResponse from(HomeworkGuidance guidance) {
      return new HomeworkGuidanceResponse(guidance.steps(), guidance.finalHint());
    }
  }
}
