package com.novalearn.application.child;

import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.child.Avatar;
import com.novalearn.domain.child.ChildProfile;
import com.novalearn.domain.child.GradeLevel;
import com.novalearn.domain.child.LearningPreference;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ChildService {

  private static final GradeLevel DEFAULT_GRADE_LEVEL = GradeLevel.GRADE_1;
  private static final Avatar DEFAULT_AVATAR = Avatar.FOX;

  private final ChildProfileRepository children;

  public ChildService(ChildProfileRepository children) {
    this.children = children;
  }

  /** Backward-compatible overload for callers that have not yet adopted grade/avatar/preferences (e.g. the current mobile client). */
  @Transactional
  public ChildProfile create(UUID parentId, String displayName, LocalDate birthDate) {
    return create(parentId, displayName, birthDate, DEFAULT_GRADE_LEVEL, DEFAULT_AVATAR, Set.of());
  }

  @Transactional
  public ChildProfile create(
      UUID parentId,
      String displayName,
      LocalDate birthDate,
      GradeLevel gradeLevel,
      Avatar avatar,
      Set<LearningPreference> learningPreferences) {
    return children.save(new ChildProfile(
        UUID.randomUUID(),
        parentId,
        displayName.trim(),
        birthDate,
        gradeLevel == null ? DEFAULT_GRADE_LEVEL : gradeLevel,
        avatar == null ? DEFAULT_AVATAR : avatar,
        learningPreferences == null ? Set.of() : Set.copyOf(learningPreferences)));
  }

  /** Edits a profile the parent owns; null fields keep their current value. Progress is keyed by id, so it is preserved. */
  @Transactional
  public ChildProfile update(
      UUID parentId,
      UUID childId,
      String displayName,
      LocalDate birthDate,
      GradeLevel gradeLevel,
      Avatar avatar) {
    if (!children.belongsToParent(childId, parentId)) {
      throw new ChildNotFoundException();
    }
    ChildProfile current = children.findById(childId).orElseThrow(ChildNotFoundException::new);
    return children.save(new ChildProfile(
        current.id(),
        current.parentId(),
        displayName == null ? current.displayName() : displayName.trim(),
        birthDate == null ? current.birthDate() : birthDate,
        gradeLevel == null ? current.gradeLevel() : gradeLevel,
        avatar == null ? current.avatar() : avatar,
        current.learningPreferences()));
  }

  @Transactional(readOnly = true)
  public List<ChildProfile> list(UUID parentId) {
    return children.findByParentId(parentId);
  }
}
