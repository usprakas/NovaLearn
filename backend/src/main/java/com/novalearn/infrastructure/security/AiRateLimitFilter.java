package com.novalearn.infrastructure.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.Duration;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * Fixed-window rate limit on the AI-backed endpoints (tutor and homework), keyed by {@code
 * childId} rather than client IP — the master spec explicitly calls out per-child/session request
 * frequency limits as a child-safety requirement, separate from the IP-based auth limiter. This
 * matters most once a real {@code ANTHROPIC_API_KEY} is configured, since unbounded calls cost
 * real money; see docs/SECURITY_AND_CHILD_SAFETY.md.
 */
@Component
public class AiRateLimitFilter extends OncePerRequestFilter {

  private static final Pattern AI_ENDPOINT_PATTERN =
      Pattern.compile("^/api/v1/children/([^/]+)/(tutor|homework)/");

  private final RedisFixedWindowRateLimiter limiter;
  private final int limitPerMinute;

  public AiRateLimitFilter(
      RedisFixedWindowRateLimiter limiter,
      @Value("${novalearn.rate-limit.ai-requests-per-minute:20}") int limitPerMinute) {
    this.limiter = limiter;
    this.limitPerMinute = limitPerMinute;
  }

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
      throws ServletException, IOException {
    Matcher matcher = AI_ENDPOINT_PATTERN.matcher(request.getRequestURI());
    if (!"POST".equals(request.getMethod()) || !matcher.find()) {
      chain.doFilter(request, response);
      return;
    }
    String childId = matcher.group(1);
    String key = "ratelimit:ai:" + childId + ":" + currentMinuteBucket();
    if (!limiter.tryAcquire(key, limitPerMinute, Duration.ofMinutes(1))) {
      TooManyRequestsResponse.write(response);
      return;
    }
    chain.doFilter(request, response);
  }

  private long currentMinuteBucket() {
    return System.currentTimeMillis() / 60_000L;
  }
}
