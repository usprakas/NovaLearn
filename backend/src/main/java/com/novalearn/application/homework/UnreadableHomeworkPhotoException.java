package com.novalearn.application.homework;

/** The photo was a valid image but no homework question could be read from it — mapped to 422. */
public class UnreadableHomeworkPhotoException extends RuntimeException {
  public UnreadableHomeworkPhotoException() {
    super("We couldn't find a homework question in that photo. Try a closer, brighter photo, or type it in.");
  }
}
