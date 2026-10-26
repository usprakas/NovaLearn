package com.novalearn.application.auth;

/** Raised without revealing whether an email address is registered. */
public class AuthenticationException extends RuntimeException {
    public AuthenticationException() {
        super("Invalid email or password");
    }
}
