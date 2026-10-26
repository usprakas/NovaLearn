package com.novalearn.application.progress;

public class ExerciseNotFoundException extends RuntimeException {
  public ExerciseNotFoundException() {
    super("Exercise was not found");
  }
}
