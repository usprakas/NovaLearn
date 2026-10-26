package com.novalearn.infrastructure.persistence;

import com.novalearn.application.progress.ExerciseAttemptRepository;
import com.novalearn.application.progress.SkillProgressRepository;
import com.novalearn.domain.progress.ExerciseAttempt;
import com.novalearn.domain.progress.SkillProgress;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import org.springframework.stereotype.Repository;

@Repository
class JpaExerciseAttemptAdapter implements ExerciseAttemptRepository {
  private final ExerciseAttemptJpaRepository repo;

  JpaExerciseAttemptAdapter(ExerciseAttemptJpaRepository repo) {
    this.repo = repo;
  }

  @Override
  public ExerciseAttempt save(ExerciseAttempt attempt) {
    ExerciseAttemptEntity saved = repo.save(new ExerciseAttemptEntity(
        attempt.id(), attempt.childId(), attempt.exerciseId(), attempt.submittedAnswerIndex(), attempt.correct(), attempt.attemptedAt()));
    return map(saved);
  }

  @Override
  public Set<UUID> findAttemptedExerciseIds(UUID childId, Set<UUID> exerciseIds) {
    if (exerciseIds.isEmpty()) {
      return Set.of();
    }
    return repo.findDistinctExerciseIdsByChildIdAndExerciseIdIn(childId, exerciseIds);
  }

  @Override
  public long countCorrectAmong(UUID childId, Set<UUID> exerciseIds) {
    if (exerciseIds.isEmpty()) {
      return 0;
    }
    return repo.countDistinctCorrectExerciseIds(childId, exerciseIds);
  }

  @Override
  public List<ExerciseAttempt> findByChildIdAndExerciseId(UUID childId, UUID exerciseId) {
    return repo.findByChildIdAndExerciseId(childId, exerciseId).stream().map(JpaExerciseAttemptAdapter::map).toList();
  }

  private static ExerciseAttempt map(ExerciseAttemptEntity e) {
    return new ExerciseAttempt(e.getId(), e.getChildId(), e.getExerciseId(), e.getSubmittedAnswerIndex(), e.isCorrect(), e.getAttemptedAt());
  }
}

@Repository
class JpaSkillProgressAdapter implements SkillProgressRepository {
  private final SkillProgressJpaRepository repo;

  JpaSkillProgressAdapter(SkillProgressJpaRepository repo) {
    this.repo = repo;
  }

  @Override
  public Optional<SkillProgress> findByChildIdAndSkillCode(UUID childId, String skillCode) {
    return repo.findById(new SkillProgressId(childId, skillCode)).map(JpaSkillProgressAdapter::map);
  }

  @Override
  public SkillProgress save(SkillProgress progress) {
    SkillProgressEntity saved = repo.save(new SkillProgressEntity(
        progress.childId(), progress.skillCode(), progress.attemptsCount(), progress.correctCount(), progress.lastAttemptAt()));
    return map(saved);
  }

  private static SkillProgress map(SkillProgressEntity e) {
    return new SkillProgress(e.getChildId(), e.getSkillCode(), e.getAttemptsCount(), e.getCorrectCount(), e.getLastAttemptAt());
  }
}
