package com.novalearn.infrastructure.persistence;

import com.novalearn.domain.child.Avatar;
import com.novalearn.domain.child.GradeLevel;
import com.novalearn.domain.child.LearningPreference;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "child_profiles")
public class ChildProfileEntity {
  @Id
  private UUID id;
  @Column(name = "parent_id", nullable = false)
  private UUID parentId;
  @Column(name = "display_name", nullable = false, length = 60)
  private String displayName;
  @Column(name = "birth_date", nullable = false)
  private LocalDate birthDate;
  @Enumerated(EnumType.STRING)
  @Column(name = "grade_level", nullable = false, length = 20)
  private GradeLevel gradeLevel;
  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 20)
  private Avatar avatar;
  @ElementCollection(fetch = FetchType.EAGER)
  @CollectionTable(name = "child_learning_preferences", joinColumns = @JoinColumn(name = "child_id"))
  @Enumerated(EnumType.STRING)
  @Column(name = "preference", length = 20)
  private Set<LearningPreference> learningPreferences = new HashSet<>();

  protected ChildProfileEntity() { }

  public ChildProfileEntity(
      UUID id, UUID parentId, String displayName, LocalDate birthDate, GradeLevel gradeLevel, Avatar avatar, Set<LearningPreference> learningPreferences) {
    this.id = id;
    this.parentId = parentId;
    this.displayName = displayName;
    this.birthDate = birthDate;
    this.gradeLevel = gradeLevel;
    this.avatar = avatar;
    this.learningPreferences = new HashSet<>(learningPreferences);
  }

  public UUID getId() { return id; }
  public UUID getParentId() { return parentId; }
  public String getDisplayName() { return displayName; }
  public LocalDate getBirthDate() { return birthDate; }
  public GradeLevel getGradeLevel() { return gradeLevel; }
  public Avatar getAvatar() { return avatar; }
  public Set<LearningPreference> getLearningPreferences() { return learningPreferences; }
}
