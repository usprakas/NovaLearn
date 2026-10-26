package com.novalearn.infrastructure.persistence;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OrderColumn;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "exercises")
public class ExerciseEntity {
  @Id
  private UUID id;
  @Column(name = "lesson_code", nullable = false, length = 100)
  private String lessonCode;
  @Column(name = "skill_code", nullable = false, length = 20)
  private String skillCode;
  @Column(name = "display_order", nullable = false)
  private int displayOrder;
  @Column(nullable = false, length = 500)
  private String prompt;
  @ElementCollection
  @CollectionTable(name = "exercise_choices", joinColumns = @JoinColumn(name = "exercise_id"))
  @OrderColumn(name = "choice_index")
  @Column(name = "choice_text", length = 200)
  private List<String> choices = new ArrayList<>();
  @Column(name = "answer_index", nullable = false)
  private int answerIndex;
  @Column(nullable = false, length = 500)
  private String explanation;
  @Column(length = 500)
  private String hint;

  protected ExerciseEntity() { }

  public ExerciseEntity(
      UUID id, String lessonCode, String skillCode, int displayOrder, String prompt, List<String> choices,
      int answerIndex, String explanation, String hint) {
    this.id = id;
    this.lessonCode = lessonCode;
    this.skillCode = skillCode;
    this.displayOrder = displayOrder;
    this.prompt = prompt;
    this.choices = new ArrayList<>(choices);
    this.answerIndex = answerIndex;
    this.explanation = explanation;
    this.hint = hint;
  }

  public UUID getId() { return id; }
  public String getLessonCode() { return lessonCode; }
  public String getSkillCode() { return skillCode; }
  public int getOrder() { return displayOrder; }
  public String getPrompt() { return prompt; }
  public List<String> getChoices() { return choices; }
  public int getAnswerIndex() { return answerIndex; }
  public String getExplanation() { return explanation; }
  public String getHint() { return hint; }
}
