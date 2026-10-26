package com.novalearn.interfaces.rest.tutor;

import com.novalearn.application.tutor.TutorService;
import com.novalearn.domain.tutor.TutorAnswer;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
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
@RequestMapping("/api/v1/children/{childId}/tutor")
@Tag(name = "AI tutor")
public class TutorController {

  private final TutorService tutor;

  public TutorController(TutorService tutor) {
    this.tutor = tutor;
  }

  @PostMapping("/questions")
  @ResponseStatus(HttpStatus.CREATED)
  public TutorAnswerResponse ask(
      @AuthenticationPrincipal UUID parentId,
      @PathVariable UUID childId,
      @RequestBody @Valid AskTutorRequest request) {
    TutorAnswer answer = tutor.ask(parentId, childId, request.question(), request.subject(), request.attempt());
    return TutorAnswerResponse.from(answer);
  }

  /** {@code question} is capped at 500 characters — "limit message size" per the child-safety requirements. */
  public record AskTutorRequest(@NotBlank @Size(max = 500) String question, String subject, @Min(0) int attempt) { }

  public record TutorAnswerResponse(String strategy, String explanation, String suggestedNextActivity, boolean refused) {
    static TutorAnswerResponse from(TutorAnswer answer) {
      return new TutorAnswerResponse(answer.strategy().name(), answer.explanation(), answer.suggestedNextActivity(), answer.refused());
    }
  }
}
