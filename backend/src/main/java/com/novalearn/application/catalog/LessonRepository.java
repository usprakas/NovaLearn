package com.novalearn.application.catalog;

import com.novalearn.domain.catalog.LessonDefinition;
import com.novalearn.domain.child.GradeLevel;
import java.util.List;
import java.util.Optional;

public interface LessonRepository {
  List<LessonDefinition> findAll();

  List<LessonDefinition> findByGradeLevel(GradeLevel gradeLevel);

  Optional<LessonDefinition> findByCode(String code);
}
