package com.novalearn.application.catalog;

import com.novalearn.domain.catalog.LessonDefinition;
import java.util.List;
import java.util.Optional;

public interface LessonRepository {
  List<LessonDefinition> findAll();

  Optional<LessonDefinition> findByCode(String code);
}
