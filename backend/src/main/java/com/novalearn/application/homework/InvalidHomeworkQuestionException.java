package com.novalearn.application.homework;

public class InvalidHomeworkQuestionException extends RuntimeException {
  public InvalidHomeworkQuestionException() {
    super("Homework question text is required");
  }
}
