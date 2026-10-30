package com.novalearn.infrastructure.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

class AuthRateLimitFilterTest {

  private final RedisFixedWindowRateLimiter limiter = mock(RedisFixedWindowRateLimiter.class);
  private final AuthRateLimitFilter filter = new AuthRateLimitFilter(limiter, 10);

  @Test
  void writesA429DirectlyRatherThanDispatchingToTheErrorPage() throws Exception {
    when(limiter.tryAcquire(anyString(), anyInt(), any())).thenReturn(false);
    MockHttpServletRequest request = new MockHttpServletRequest("POST", "/api/v1/auth/login");
    MockHttpServletResponse response = new MockHttpServletResponse();
    FilterChain chain = mock(FilterChain.class);

    filter.doFilter(request, response, chain);

    assertThat(response.getStatus()).isEqualTo(429);
    assertThat(response.getErrorMessage()).isNull();
    assertThat(response.getHeader("Retry-After")).isEqualTo("60");
    assertThat(response.getContentAsString()).contains("\"status\":429", "\"detail\":\"Too many requests");
    verify(chain, never()).doFilter(any(), any());
  }

  @Test
  void passesThroughWhenUnderTheLimit() throws Exception {
    when(limiter.tryAcquire(anyString(), anyInt(), any())).thenReturn(true);
    MockHttpServletRequest request = new MockHttpServletRequest("POST", "/api/v1/auth/login");
    MockHttpServletResponse response = new MockHttpServletResponse();
    FilterChain chain = mock(FilterChain.class);

    filter.doFilter(request, response, chain);

    verify(chain).doFilter(request, response);
  }
}
