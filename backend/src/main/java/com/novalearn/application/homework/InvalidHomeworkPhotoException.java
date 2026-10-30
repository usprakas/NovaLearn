package com.novalearn.application.homework;

/** The upload is missing, too large, or not a JPEG/PNG/WebP image — mapped to 400. */
public class InvalidHomeworkPhotoException extends RuntimeException {
  public InvalidHomeworkPhotoException(String message) {
    super(message);
  }
}
