package com.novalearn.domain.catalog;

import java.util.List;

public record LessonDefinition(
    String code,
    String subject,
    int order,
    String title,
    String description,
    List<LessonQuestion> questions) { }
