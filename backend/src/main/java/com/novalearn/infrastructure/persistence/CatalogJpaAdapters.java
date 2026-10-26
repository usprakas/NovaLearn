package com.novalearn.infrastructure.persistence;

import com.novalearn.application.catalog.ExerciseAnswerKey;
import com.novalearn.application.catalog.ExerciseRepository;
import com.novalearn.application.catalog.LessonRepository;
import com.novalearn.domain.catalog.Exercise;
import com.novalearn.domain.catalog.LessonDefinition;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.stereotype.Repository;

@Repository
class JpaLessonAdapter implements LessonRepository {
  private final LessonJpaRepository repo;

  JpaLessonAdapter(LessonJpaRepository repo) {
    this.repo = repo;
  }

  @Override
  public List<LessonDefinition> findAll() {
    return repo.findAll().stream().map(JpaLessonAdapter::map).toList();
  }

  @Override
  public Optional<LessonDefinition> findByCode(String code) {
    return repo.findByCode(code).map(JpaLessonAdapter::map);
  }

  private static LessonDefinition map(LessonEntity e) {
    return new LessonDefinition(e.getCode(), e.getSubjectCode(), e.getOrder(), e.getTitle(), e.getDescription());
  }
}

@Repository
class JpaExerciseAdapter implements ExerciseRepository {
  private final ExerciseJpaRepository repo;

  JpaExerciseAdapter(ExerciseJpaRepository repo) {
    this.repo = repo;
  }

  @Override
  public List<Exercise> findByLessonCode(String lessonCode) {
    return repo.findByLessonCodeOrderByDisplayOrder(lessonCode).stream().map(JpaExerciseAdapter::map).toList();
  }

  @Override
  public Optional<Exercise> findById(UUID exerciseId) {
    return repo.findById(exerciseId).map(JpaExerciseAdapter::map);
  }

  @Override
  public int countByLessonCode(String lessonCode) {
    return repo.countByLessonCode(lessonCode);
  }

  @Override
  public Optional<ExerciseAnswerKey> findAnswerKey(UUID exerciseId) {
    return repo.findById(exerciseId)
        .map(e -> new ExerciseAnswerKey(e.getSkillCode(), e.getAnswerIndex(), e.getExplanation(), e.getHint()));
  }

  private static Exercise map(ExerciseEntity e) {
    // List.copyOf forces the lazy @ElementCollection to materialize here, while the JPA session
    // from the calling @Transactional method is still open — without this, the Exercise record
    // would carry a live Hibernate proxy that throws LazyInitializationException the moment
    // something (e.g. JSON serialization) touches it after the session closes.
    return new Exercise(e.getId(), e.getLessonCode(), e.getSkillCode(), e.getOrder(), e.getPrompt(), List.copyOf(e.getChoices()));
  }
}
