package com.novalearn.interfaces.rest.progress;

import com.novalearn.application.progress.ProgressService;
import com.novalearn.domain.progress.LessonProgress;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Read-only: a lesson's score/completion is derived from exercise attempts (see
 * {@code ExerciseAttemptController}), not submitted directly. There used to be a
 * {@code PUT .../progress/{lessonCode}} here that let a client set its own score/completion —
 * removed because nothing verified it server-side. See docs/RISKS_AND_TRADEOFFS.md.
 */
@RestController
@RequestMapping("/api/v1/children/{childId}/progress")
@Tag(name = "Learning progress")
public class ProgressController {

  private final ProgressService progress;

  public ProgressController(ProgressService progress) {
    this.progress = progress;
  }

  @GetMapping
  public List<ProgressResponse> list(@AuthenticationPrincipal UUID parentId, @PathVariable UUID childId) {
    return progress.list(parentId, childId).stream().map(ProgressController::map).toList();
  }

  private static ProgressResponse map(LessonProgress progress) {
    return new ProgressResponse(progress.id(), progress.lessonCode(), progress.score(), progress.completed(), progress.updatedAt());
  }

  public record ProgressResponse(UUID id, String lessonCode, int score, boolean completed, Instant updatedAt) { }
}
