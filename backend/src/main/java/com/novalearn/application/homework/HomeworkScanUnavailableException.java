package com.novalearn.application.homework;

/** No vision provider is configured, or the provider call failed — mapped to 503. */
public class HomeworkScanUnavailableException extends RuntimeException {
  public HomeworkScanUnavailableException() {
    super("Photo scanning isn't available right now. Please type the question instead.");
  }
}
