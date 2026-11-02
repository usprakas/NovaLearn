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
    response.setHeader("X-Proxy-Shape", proxyShape(request)); // TEMP diagnostic, no IP values
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

  // TEMP: describes which proxy headers arrive and how they relate, without exposing any address.
  private String proxyShape(HttpServletRequest request) {
    String xff = request.getHeader("X-Forwarded-For");
    String[] parts = xff == null ? new String[0] : xff.split(",");
    String first = parts.length > 0 ? parts[0].trim() : null;
    String last = parts.length > 0 ? parts[parts.length - 1].trim() : null;
    String cf = request.getHeader("CF-Connecting-IP");
    String tci = request.getHeader("True-Client-IP");
    String xri = request.getHeader("X-Real-IP");
    return "xff=" + parts.length
        + ";cf=" + (cf != null) + ";tci=" + (tci != null) + ";xri=" + (xri != null)
        + ";cfEqFirst=" + (cf != null && cf.equals(first)) + ";cfEqLast=" + (cf != null && cf.equals(last))
        + ";tciEqLast=" + (tci != null && tci.equals(last)) + ";xriEqLast=" + (xri != null && xri.equals(last))
        + ";remoteEqLast=" + request.getRemoteAddr().equals(last);
  }

  private String clientKey(HttpServletRequest request) {
    String forwarded = request.getHeader("X-Forwarded-For");
    if (forwarded != null && !forwarded.isBlank()) {
      return forwarded.split(",")[0].trim();
    }
    return request.getRemoteAddr();
  }
}
