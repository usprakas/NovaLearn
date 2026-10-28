package com.novalearn.application.progress;

import com.novalearn.application.catalog.ExerciseAnswerKey;
import com.novalearn.application.catalog.ExerciseRepository;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.catalog.Exercise;
import com.novalearn.domain.progress.ExerciseAttempt;
import com.novalearn.domain.progress.ExerciseEvaluation;
import com.novalearn.domain.progress.SkillProgress;
import java.time.Instant;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * The server-side answer check this API never had before: the correct answer index lives only in
 * {@link ExerciseAnswerKey}, fetched here and never returned to a controller, so a client cannot
 * recover it by inspecting any response.
 */
@Service
public class ExerciseEvaluationService {

  private final ChildProfileRepository children;
  private final ExerciseRepository exercises;
  private final ExerciseAttemptRepository attempts;
  private final SkillProgressRepository skillProgress;
  private final ProgressService progressService;

  public ExerciseEvaluationService(
      ChildProfileRepository children,
      ExerciseRepository exercises,
      ExerciseAttemptRepository attempts,
      SkillProgressRepository skillProgress,
      ProgressService progressService) {
    this.children = children;
    this.exercises = exercises;
    this.attempts = attempts;
    this.skillProgress = skillProgress;
    this.progressService = progressService;
  }

  @Transactional
  public ExerciseEvaluation submitAnswer(UUID parentId, UUID childId, UUID exerciseId, int submittedAnswerIndex) {
    if (!children.belongsToParent(childId, parentId)) {
      throw new ChildNotFoundException();
    }
    Exercise exercise = exercises.findById(exerciseId).orElseThrow(ExerciseNotFoundException::new);
    ExerciseAnswerKey answerKey = exercises.findAnswerKey(exerciseId).orElseThrow(ExerciseNotFoundException::new);
    boolean correct = submittedAnswerIndex == answerKey.correctAnswerIndex();

    attempts.save(new ExerciseAttempt(UUID.randomUUID(), childId, exerciseId, submittedAnswerIndex, correct, Instant.now()));
    recordSkillProgress(childId, answerKey.skillCode(), correct);
    progressService.recalculate(childId, exercise.lessonCode());

    String correctChoiceText = exercise.choices().get(answerKey.correctAnswerIndex());
    return new ExerciseEvaluation(correct, answerKey.explanation(), correct ? null : answerKey.hint(), correctChoiceText);
  }

  private void recordSkillProgress(UUID childId, String skillCode, boolean correct) {
    SkillProgress current = skillProgress.findByChildIdAndSkillCode(childId, skillCode).orElse(SkillProgress.initial(childId, skillCode));
    skillProgress.save(new SkillProgress(
        childId, skillCode, current.attemptsCount() + 1, current.correctCount() + (correct ? 1 : 0), Instant.now()));
  }
}
