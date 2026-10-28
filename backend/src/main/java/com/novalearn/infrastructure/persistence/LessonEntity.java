package com.novalearn.infrastructure.persistence;

import com.novalearn.domain.child.GradeLevel;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;

@Entity
@Table(name = "lessons")
public class LessonEntity {
  @Id
  private UUID id;
  @Column(nullable = false, unique = true, length = 100)
  private String code;
  @Column(name = "subject_code", nullable = false, length = 20)
  private String subjectCode;
  @Enumerated(EnumType.STRING)
  @Column(name = "grade_level", nullable = false, length = 20)
  private GradeLevel gradeLevel;
  @Column(name = "display_order", nullable = false)
  private int displayOrder;
  @Column(nullable = false, length = 200)
  private String title;
  @Column(nullable = false, length = 500)
  private String description;

  protected LessonEntity() { }

  public LessonEntity(
      UUID id, String code, String subjectCode, GradeLevel gradeLevel, int displayOrder, String title,
      String description) {
    this.id = id;
    this.code = code;
    this.subjectCode = subjectCode;
    this.gradeLevel = gradeLevel;
    this.displayOrder = displayOrder;
    this.title = title;
    this.description = description;
  }

  public UUID getId() { return id; }
  public String getCode() { return code; }
  public String getSubjectCode() { return subjectCode; }
  public GradeLevel getGradeLevel() { return gradeLevel; }
  public int getOrder() { return displayOrder; }
  public String getTitle() { return title; }
  public String getDescription() { return description; }
}
