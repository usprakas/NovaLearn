package com.novalearn.infrastructure.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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
  @Column(name = "display_order", nullable = false)
  private int displayOrder;
  @Column(nullable = false, length = 200)
  private String title;
  @Column(nullable = false, length = 500)
  private String description;

  protected LessonEntity() { }

  public LessonEntity(UUID id, String code, String subjectCode, int displayOrder, String title, String description) {
    this.id = id;
    this.code = code;
    this.subjectCode = subjectCode;
    this.displayOrder = displayOrder;
    this.title = title;
    this.description = description;
  }

  public UUID getId() { return id; }
  public String getCode() { return code; }
  public String getSubjectCode() { return subjectCode; }
  public int getOrder() { return displayOrder; }
  public String getTitle() { return title; }
  public String getDescription() { return description; }
}
