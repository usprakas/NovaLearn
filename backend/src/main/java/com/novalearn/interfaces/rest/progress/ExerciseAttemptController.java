package com.novalearn.interfaces.rest.progress;

import com.novalearn.application.progress.ExerciseEvaluationService;
import com.novalearn.domain.progress.ExerciseEvaluation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
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
@RequestMapping("/api/v1/children/{childId}/exercises/{exerciseId}/attempts")
@Tag(name = "Exercise evaluation")
public class ExerciseAttemptController {

  private final ExerciseEvaluationService evaluation;

  public ExerciseAttemptController(ExerciseEvaluationService evaluation) {
    this.evaluation = evaluation;
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public ExerciseEvaluationResponse submit(
      @AuthenticationPrincipal UUID parentId,
      @PathVariable UUID childId,
      @PathVariable UUID exerciseId,
      @RequestBody @Valid SubmitAnswerRequest request) {
    return ExerciseEvaluationResponse.from(evaluation.submitAnswer(parentId, childId, exerciseId, request.submittedAnswerIndex()));
  }

  public record SubmitAnswerRequest(@Min(0) int submittedAnswerIndex) { }

  public record ExerciseEvaluationResponse(boolean correct, String explanation, String hint, String correctChoiceText) {
    static ExerciseEvaluationResponse from(ExerciseEvaluation evaluation) {
      return new ExerciseEvaluationResponse(
          evaluation.correct(), evaluation.explanation(), evaluation.hint(), evaluation.correctChoiceText());
    }
  }
}
