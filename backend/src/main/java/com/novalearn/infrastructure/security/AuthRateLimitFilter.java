package com.novalearn.infrastructure.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.Duration;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * Fixed-window rate limit on POST /api/v1/auth/** (register/login/refresh/logout), keyed by
 * client IP. See {@link RedisFixedWindowRateLimiter} for the fail-open behavior if Redis is down.
 */
@Component
public class AuthRateLimitFilter extends OncePerRequestFilter {

  private final RedisFixedWindowRateLimiter limiter;
  private final int limitPerMinute;

  public AuthRateLimitFilter(
      RedisFixedWindowRateLimiter limiter,
      @Value("${novalearn.rate-limit.auth-attempts-per-minute:10}") int limitPerMinute) {
    this.limiter = limiter;
    this.limitPerMinute = limitPerMinute;
  }

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
      throws ServletException, IOException {
    if (!isAuthEndpoint(request)) {
      chain.doFilter(request, response);
      return;
    }
    String key = "ratelimit:auth:" + clientKey(request) + ":" + currentMinuteBucket();
    if (!limiter.tryAcquire(key, limitPerMinute, Duration.ofMinutes(1))) {
      TooManyRequestsResponse.write(response);
      return;
    }
    chain.doFilter(request, response);
  }

  private boolean isAuthEndpoint(HttpServletRequest request) {
    return "POST".equals(request.getMethod()) && request.getRequestURI().startsWith("/api/v1/auth/");
  }

  private long currentMinuteBucket() {
    return System.currentTimeMillis() / 60_000L;
  }

  private String clientKey(HttpServletRequest request) {
    String forwarded = request.getHeader("X-Forwarded-For");
    if (forwarded != null && !forwarded.isBlank()) {
      return forwarded.split(",")[0].trim();
    }
    return request.getRemoteAddr();
  }
}
