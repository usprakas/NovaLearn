package com.novalearn.application.catalog;

import com.novalearn.domain.catalog.Exercise;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ExerciseRepository {
  List<Exercise> findByLessonCode(String lessonCode);

  Optional<Exercise> findById(UUID exerciseId);

  int countByLessonCode(String lessonCode);

  /** Deliberately a separate accessor from {@link #findById} — see {@link ExerciseAnswerKey}'s Javadoc for why. */
  Optional<ExerciseAnswerKey> findAnswerKey(UUID exerciseId);
}
