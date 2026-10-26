package com.novalearn.application.auth;

public class EmailAlreadyRegisteredException extends RuntimeException { public EmailAlreadyRegisteredException() { super("An account already exists for this email"); } }
