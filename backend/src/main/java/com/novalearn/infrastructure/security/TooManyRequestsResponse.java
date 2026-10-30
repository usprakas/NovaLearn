package com.novalearn.infrastructure.security;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.Instant;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;

/**
 * Writes a 429 directly, in the same {@code {timestamp, status, detail}} shape as
 * {@code ApiExceptionHandler.ApiError}. The rate-limit filters must not use
 * {@code response.sendError}: that forwards to {@code /error}, which Spring Security rejects for an
 * anonymous caller, turning the 429 into a 403.
 */
final class TooManyRequestsResponse {

  private TooManyRequestsResponse() {}

  static void write(HttpServletResponse response) throws IOException {
    response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
    response.setHeader("Retry-After", "60");
    response.setContentType(MediaType.APPLICATION_JSON_VALUE);
    response.getWriter().write("{\"timestamp\":\"" + Instant.now() + "\",\"status\":429,"
        + "\"detail\":\"Too many requests, please try again later\"}");
  }
}
