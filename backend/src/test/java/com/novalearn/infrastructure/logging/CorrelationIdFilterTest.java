package com.novalearn.infrastructure.logging;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.Test;
import org.slf4j.MDC;

class CorrelationIdFilterTest {

  private final CorrelationIdFilter filter = new CorrelationIdFilter();

  @Test
  void generatesAndEchoesACorrelationIdWhenTheClientSendsNone() throws Exception {
    HttpServletRequest request = mock(HttpServletRequest.class);
    HttpServletResponse response = mock(HttpServletResponse.class);
    FilterChain chain = mock(FilterChain.class);

    filter.doFilter(request, response, chain);

    verify(response).setHeader(eq(CorrelationIdFilter.HEADER), argThat(id -> id != null && !id.isBlank()));
    verify(chain).doFilter(request, response);
    assertThat(MDC.get("correlationId")).isNull();
  }

  @Test
  void reusesAClientSuppliedCorrelationId() throws Exception {
    HttpServletRequest request = mock(HttpServletRequest.class);
    when(request.getHeader(CorrelationIdFilter.HEADER)).thenReturn("mobile-trace-123");
    HttpServletResponse response = mock(HttpServletResponse.class);
    FilterChain chain = mock(FilterChain.class);

    filter.doFilter(request, response, chain);

    verify(response).setHeader(CorrelationIdFilter.HEADER, "mobile-trace-123");
  }

  @Test
  void clearsTheMdcEntryEvenWhenTheChainThrows() {
    HttpServletRequest request = mock(HttpServletRequest.class);
    HttpServletResponse response = mock(HttpServletResponse.class);
    FilterChain chain = mock(FilterChain.class);

    org.assertj.core.api.Assertions.assertThatCode(() -> {
      try {
        org.mockito.Mockito.doThrow(new RuntimeException("boom")).when(chain).doFilter(request, response);
        filter.doFilter(request, response, chain);
      } catch (RuntimeException expected) {
        // expected: the filter must still propagate the chain's exception
      }
    }).doesNotThrowAnyException();
    assertThat(MDC.get("correlationId")).isNull();
  }
}
