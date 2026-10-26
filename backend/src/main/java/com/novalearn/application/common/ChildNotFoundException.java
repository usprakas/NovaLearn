package com.novalearn.application.common;

/** Thrown whenever a child id does not exist or does not belong to the authenticated parent. */
public class ChildNotFoundException extends RuntimeException {
  public ChildNotFoundException() {
    super("Child profile was not found");
  }
}
