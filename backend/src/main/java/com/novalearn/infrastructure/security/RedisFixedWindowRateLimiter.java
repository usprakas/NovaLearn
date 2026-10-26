package com.novalearn.infrastructure.security;

import java.time.Duration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

/**
 * Shared fixed-window counter backing both {@link AuthRateLimitFilter} and {@link AiRateLimitFilter}.
 * Redis is an optional dependency for this MVP: if it is unreachable, {@link #tryAcquire} fails
 * open (returns {@code true}) and logs a warning, rather than failing the whole API.
 */
@Component
public class RedisFixedWindowRateLimiter {

  private static final Logger log = LoggerFactory.getLogger(RedisFixedWindowRateLimiter.class);

  private final StringRedisTemplate redis;

  public RedisFixedWindowRateLimiter(StringRedisTemplate redis) {
    this.redis = redis;
  }

  public boolean tryAcquire(String key, int limitPerWindow, Duration window) {
    try {
      Long count = redis.opsForValue().increment(key);
      if (count != null && count == 1L) {
        redis.expire(key, window);
      }
      return count == null || count <= limitPerWindow;
    } catch (RuntimeException redisUnavailable) {
      log.warn("Rate limiter could not reach Redis for key '{}'; allowing the request", key, redisUnavailable);
      return true;
    }
  }
}
