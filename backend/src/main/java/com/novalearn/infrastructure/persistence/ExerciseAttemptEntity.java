package com.novalearn.infrastructure.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "exercise_attempts")
public class ExerciseAttemptEntity {
  @Id
  private UUID id;
  @Column(name = "child_id", nullable = false)
  private UUID childId;
  @Column(name = "exercise_id", nullable = false)
  private UUID exerciseId;
  @Column(name = "submitted_answer_index", nullable = false)
  private int submittedAnswerIndex;
  @Column(nullable = false)
  private boolean correct;
  @Column(name = "attempted_at", nullable = false)
  private Instant attemptedAt;

  protected ExerciseAttemptEntity() { }

  public ExerciseAttemptEntity(UUID id, UUID childId, UUID exerciseId, int submittedAnswerIndex, boolean correct, Instant attemptedAt) {
    this.id = id;
    this.childId = childId;
    this.exerciseId = exerciseId;
    this.submittedAnswerIndex = submittedAnswerIndex;
    this.correct = correct;
    this.attemptedAt = attemptedAt;
  }

  public UUID getId() { return id; }
  public UUID getChildId() { return childId; }
  public UUID getExerciseId() { return exerciseId; }
  public int getSubmittedAnswerIndex() { return submittedAnswerIndex; }
  public boolean isCorrect() { return correct; }
  public Instant getAttemptedAt() { return attemptedAt; }
}
