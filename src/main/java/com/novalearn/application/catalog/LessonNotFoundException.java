package com.novalearn.application.catalog;

public class LessonNotFoundException extends RuntimeException {
  public LessonNotFoundException() {
    super("Lesson was not found");
  }
}
