package com.novalearn.infrastructure.security;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

/**
 * Shared fixed-window counter backing both {@link AuthRateLimitFilter} and {@link AiRateLimitFilter}.
 * Redis is an optional dependency for this MVP: if it is unreachable, {@link #tryAcquire} falls
 * back to an in-process counter instead of failing the whole API. That fallback is exact for a
 * single instance (the current Render deployment) and per-instance if the API is ever scaled out —
 * either way the limits are still enforced, unlike failing open.
 */
@Component
public class RedisFixedWindowRateLimiter {

  private static final Logger log = LoggerFactory.getLogger(RedisFixedWindowRateLimiter.class);

  private final StringRedisTemplate redis;
  private final Clock clock;
  private final Map<String, Window> localWindows = new ConcurrentHashMap<>();
  private final AtomicBoolean redisAvailable = new AtomicBoolean(true);

  public RedisFixedWindowRateLimiter(StringRedisTemplate redis, Clock clock) {
    this.redis = redis;
    this.clock = clock;
  }

  public boolean tryAcquire(String key, int limitPerWindow, Duration window) {
    try {
      Long count = redis.opsForValue().increment(key);
      if (count != null && count == 1L) {
        redis.expire(key, window);
      }
      if (redisAvailable.compareAndSet(false, true)) {
        log.info("Rate limiter reconnected to Redis");
      }
      return count == null || count <= limitPerWindow;
    } catch (RuntimeException redisUnavailable) {
      if (redisAvailable.compareAndSet(true, false)) {
        log.warn("Rate limiter could not reach Redis; using the in-process fallback counter: {}",
            redisUnavailable.toString());
      }
      return tryAcquireLocally(key, limitPerWindow, window);
    }
  }

  private boolean tryAcquireLocally(String key, int limitPerWindow, Duration window) {
    Instant now = clock.instant();
    localWindows.values().removeIf(w -> !now.isBefore(w.expiresAt()));
    Window updated = localWindows.compute(key, (k, existing) ->
        existing == null ? new Window(1, now.plus(window)) : new Window(existing.count() + 1, existing.expiresAt()));
    return updated.count() <= limitPerWindow;
  }

  private record Window(long count, Instant expiresAt) {}
}
