package com.novalearn.domain.catalog;

/** Lesson metadata only — its exercises are a separate resource (see {@link Exercise}) so the answer key is never embedded in the same payload a client fetches to display the lesson. */
public record LessonDefinition(String code, String subject, int order, String title, String description) { }
