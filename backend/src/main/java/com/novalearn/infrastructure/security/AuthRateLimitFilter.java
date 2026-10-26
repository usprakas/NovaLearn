package com.novalearn.infrastructure.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.Duration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * Fixed-window rate limit on POST /api/v1/auth/** (register/login/refresh/logout), backed by
 * Redis, keyed by client IP. Redis is an optional dependency for this MVP: if it is unreachable,
 * the filter logs a warning and allows the request rather than failing the whole API.
 */
@Component
public class AuthRateLimitFilter extends OncePerRequestFilter {

  private static final Logger log = LoggerFactory.getLogger(AuthRateLimitFilter.class);

  private final StringRedisTemplate redis;
  private final int limitPerMinute;

  public AuthRateLimitFilter(
      StringRedisTemplate redis,
      @Value("${novalearn.rate-limit.auth-attempts-per-minute:10}") int limitPerMinute) {
    this.redis = redis;
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
    try {
      Long count = redis.opsForValue().increment(key);
      if (count != null && count == 1L) {
        redis.expire(key, Duration.ofMinutes(1));
      }
      if (count != null && count > limitPerMinute) {
        response.sendError(HttpStatus.TOO_MANY_REQUESTS.value(), "Too many requests, please try again later");
        return;
      }
    } catch (RuntimeException redisUnavailable) {
      log.warn("Rate limiter could not reach Redis; allowing the request without a limit check", redisUnavailable);
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
