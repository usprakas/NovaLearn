package com.novalearn.domain.catalog;

import java.util.List;

public record LessonQuestion(String prompt, List<String> choices, int answerIndex) { }
