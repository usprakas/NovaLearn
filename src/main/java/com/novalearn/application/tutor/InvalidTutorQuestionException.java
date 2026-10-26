package com.novalearn.application.tutor;

public class InvalidTutorQuestionException extends RuntimeException {
  public InvalidTutorQuestionException() {
    super("A question is required");
  }
}
