package com.novalearn.application.progress;

import com.novalearn.domain.progress.ExerciseAttempt;
import java.util.List;
import java.util.Set;
import java.util.UUID;

public interface ExerciseAttemptRepository {
  ExerciseAttempt save(ExerciseAttempt attempt);

  /** Distinct exercise ids, among {@code exerciseIds}, that this child has attempted at least once. */
  Set<UUID> findAttemptedExerciseIds(UUID childId, Set<UUID> exerciseIds);

  /** Among {@code exerciseIds}, how many this child has ever answered correctly at least once. */
  long countCorrectAmong(UUID childId, Set<UUID> exerciseIds);

  List<ExerciseAttempt> findByChildIdAndExerciseId(UUID childId, UUID exerciseId);
}
