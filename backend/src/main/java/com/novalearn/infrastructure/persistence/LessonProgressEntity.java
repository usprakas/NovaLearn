package com.novalearn.infrastructure.persistence;
import jakarta.persistence.*; import java.time.Instant; import java.util.UUID;
@Entity @Table(name="lesson_progress", uniqueConstraints=@UniqueConstraint(name="uk_lesson_progress_child_lesson", columnNames={"child_id","lesson_code"})) public class LessonProgressEntity {
 @Id private UUID id; @Column(name="child_id",nullable=false) private UUID childId; @Column(name="lesson_code",nullable=false,length=100) private String lessonCode; @Column(nullable=false) private int score; @Column(nullable=false) private boolean completed; @Column(name="updated_at",nullable=false) private Instant updatedAt;
 protected LessonProgressEntity(){} public LessonProgressEntity(UUID id,UUID childId,String lessonCode,int score,boolean completed,Instant updatedAt){this.id=id;this.childId=childId;this.lessonCode=lessonCode;this.score=score;this.completed=completed;this.updatedAt=updatedAt;}
 public UUID getId(){return id;} public UUID getChildId(){return childId;} public String getLessonCode(){return lessonCode;} public int getScore(){return score;} public boolean isCompleted(){return completed;} public Instant getUpdatedAt(){return updatedAt;}
}
