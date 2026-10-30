package com.novalearn.interfaces.rest.homework;

import com.novalearn.application.homework.HomeworkScanService;
import com.novalearn.application.homework.HomeworkService;
import com.novalearn.application.homework.InvalidHomeworkPhotoException;
import com.novalearn.domain.homework.HomeworkGuidance;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.Base64;
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
  private final HomeworkScanService scanner;

  public HomeworkController(HomeworkService homework, HomeworkScanService scanner) {
    this.homework = homework;
    this.scanner = scanner;
  }

  @PostMapping("/questions")
  @ResponseStatus(HttpStatus.CREATED)
  public HomeworkGuidanceResponse explain(
      @AuthenticationPrincipal UUID parentId,
      @PathVariable UUID childId,
      @RequestBody @Valid ExplainHomeworkRequest request) {
    return HomeworkGuidanceResponse.from(homework.explain(parentId, childId, request.questionText()));
  }

  /**
   * Reads the question off a worksheet photo and returns it as text for the user to check before
   * submitting it to {@code /questions}. The photo is not stored.
   */
  @PostMapping("/scans")
  public ScanHomeworkResponse scan(
      @AuthenticationPrincipal UUID parentId,
      @PathVariable UUID childId,
      @RequestBody @Valid ScanHomeworkRequest request) {
    byte[] image;
    try {
      image = Base64.getDecoder().decode(request.imageBase64());
    } catch (IllegalArgumentException notBase64) {
      throw new InvalidHomeworkPhotoException("The photo could not be read");
    }
    return new ScanHomeworkResponse(scanner.scan(parentId, childId, image));
  }

  /** Base64 of at most {@link HomeworkScanService#MAX_IMAGE_BYTES} raw bytes (4/3 expansion). */
  public record ScanHomeworkRequest(
      @NotBlank @Size(max = (HomeworkScanService.MAX_IMAGE_BYTES / 3 + 1) * 4,
          message = "That photo is too large (max 5 MB)") String imageBase64) { }

  public record ScanHomeworkResponse(String questionText) { }

  /** Capped at 500 characters — "limit message size" per the child-safety requirements. */
  public record ExplainHomeworkRequest(@NotBlank @Size(max = 500) String questionText) { }

  public record HomeworkGuidanceResponse(List<String> steps, String finalHint) {
    static HomeworkGuidanceResponse from(HomeworkGuidance guidance) {
      return new HomeworkGuidanceResponse(guidance.steps(), guidance.finalHint());
    }
  }
}
