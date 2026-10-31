package com.novalearn.interfaces.rest.child;

import com.novalearn.application.child.ChildService;
import com.novalearn.domain.child.Avatar;
import com.novalearn.domain.child.ChildProfile;
import com.novalearn.domain.child.GradeLevel;
import com.novalearn.domain.child.LearningPreference;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/children")
@Tag(name = "Children")
public class ChildController {

  private final ChildService children;

  public ChildController(ChildService children) {
    this.children = children;
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public ChildResponse create(@AuthenticationPrincipal UUID parentId, @RequestBody @Valid CreateChildRequest request) {
    return map(children.create(
        parentId,
        request.displayName(),
        request.birthDate(),
        request.gradeLevel(),
        request.avatar(),
        request.learningPreferences() == null ? Set.of() : Set.copyOf(request.learningPreferences())));
  }

  @GetMapping
  public List<ChildResponse> list(@AuthenticationPrincipal UUID parentId) {
    return children.list(parentId).stream().map(ChildController::map).toList();
  }

  @PatchMapping("/{childId}")
  public ChildResponse update(
      @AuthenticationPrincipal UUID parentId,
      @PathVariable UUID childId,
      @RequestBody @Valid UpdateChildRequest request) {
    return map(children.update(
        parentId, childId, request.displayName(), request.birthDate(), request.gradeLevel(), request.avatar()));
  }

  private static ChildResponse map(ChildProfile profile) {
    return new ChildResponse(
        profile.id(), profile.displayName(), profile.birthDate(), profile.gradeLevel(), profile.avatar(), profile.learningPreferences());
  }

  /** gradeLevel/avatar/learningPreferences are optional: omitting them defaults to GRADE_1 / FOX / no preferences, so older clients keep working. */
  public record CreateChildRequest(
      @NotBlank @Size(max = 60) String displayName,
      @NotNull @Past LocalDate birthDate,
      GradeLevel gradeLevel,
      Avatar avatar,
      Set<LearningPreference> learningPreferences) { }

  /** Every field is optional; omitted fields keep their current value. */
  public record UpdateChildRequest(
      @Size(min = 1, max = 60) @Pattern(regexp = ".*\\S.*") String displayName,
      @Past LocalDate birthDate,
      GradeLevel gradeLevel,
      Avatar avatar) { }

  public record ChildResponse(
      UUID id, String displayName, LocalDate birthDate, GradeLevel gradeLevel, Avatar avatar, Set<LearningPreference> learningPreferences) { }
}
