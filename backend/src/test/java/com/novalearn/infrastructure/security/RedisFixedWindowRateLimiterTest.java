package com.novalearn.infrastructure.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import org.junit.jupiter.api.Test;
import org.springframework.data.redis.RedisConnectionFailureException;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

class RedisFixedWindowRateLimiterTest {

  private static final Duration MINUTE = Duration.ofMinutes(1);

  @Test
  void stillEnforcesTheLimitWhenRedisIsUnreachable() {
    RedisFixedWindowRateLimiter limiter = new RedisFixedWindowRateLimiter(unreachableRedis(), fixedClock(0));

    assertThat(limiter.tryAcquire("k", 2, MINUTE)).isTrue();
    assertThat(limiter.tryAcquire("k", 2, MINUTE)).isTrue();
    assertThat(limiter.tryAcquire("k", 2, MINUTE)).isFalse();
    assertThat(limiter.tryAcquire("other-key", 2, MINUTE)).isTrue();
  }

  @Test
  void fallbackWindowResetsAfterItExpires() {
    Clock clock = mock(Clock.class);
    when(clock.instant()).thenReturn(Instant.ofEpochSecond(0), Instant.ofEpochSecond(30), Instant.ofEpochSecond(61));
    RedisFixedWindowRateLimiter limiter = new RedisFixedWindowRateLimiter(unreachableRedis(), clock);

    assertThat(limiter.tryAcquire("k", 1, MINUTE)).isTrue();
    assertThat(limiter.tryAcquire("k", 1, MINUTE)).isFalse();
    assertThat(limiter.tryAcquire("k", 1, MINUTE)).isTrue();
  }

  @Test
  void usesRedisCountWhenReachable() {
    StringRedisTemplate redis = mock(StringRedisTemplate.class);
    @SuppressWarnings("unchecked")
    ValueOperations<String, String> ops = mock(ValueOperations.class);
    when(redis.opsForValue()).thenReturn(ops);
    when(ops.increment("k")).thenReturn(1L, 2L, 3L);
    RedisFixedWindowRateLimiter limiter = new RedisFixedWindowRateLimiter(redis, fixedClock(0));

    assertThat(limiter.tryAcquire("k", 2, MINUTE)).isTrue();
    assertThat(limiter.tryAcquire("k", 2, MINUTE)).isTrue();
    assertThat(limiter.tryAcquire("k", 2, MINUTE)).isFalse();
  }

  private static StringRedisTemplate unreachableRedis() {
    StringRedisTemplate redis = mock(StringRedisTemplate.class);
    @SuppressWarnings("unchecked")
    ValueOperations<String, String> ops = mock(ValueOperations.class);
    when(redis.opsForValue()).thenReturn(ops);
    when(ops.increment(anyString())).thenThrow(new RedisConnectionFailureException("connection refused"));
    return redis;
  }

  private static Clock fixedClock(long epochSeconds) {
    return Clock.fixed(Instant.ofEpochSecond(epochSeconds), ZoneOffset.UTC);
  }
}
