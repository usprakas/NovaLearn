package com.novalearn.infrastructure.logging;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;
import org.slf4j.MDC;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * Attaches a correlation ID to every request's logs (via MDC) and echoes it back in the response,
 * so a parent-reported issue can be traced across every log line a single request produced. Reuses
 * a client-supplied {@code X-Correlation-Id} when present (lets the mobile app tie its own logs to
 * the backend's), generating one otherwise.
 */
@Component
public class CorrelationIdFilter extends OncePerRequestFilter {

  public static final String HEADER = "X-Correlation-Id";
  private static final String MDC_KEY = "correlationId";
  private static final String REQUEST_ATTRIBUTE = CorrelationIdFilter.class.getName() + ".id";

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
      throws ServletException, IOException {
    String existing = (String) request.getAttribute(REQUEST_ATTRIBUTE);
    String correlationId = existing != null ? existing : resolveCorrelationId(request);
    request.setAttribute(REQUEST_ATTRIBUTE, correlationId);
    response.setHeader(HEADER, correlationId);
    MDC.put(MDC_KEY, correlationId);
    try {
      chain.doFilter(request, response);
    } finally {
      MDC.remove(MDC_KEY);
    }
  }

  private String resolveCorrelationId(HttpServletRequest request) {
    String header = request.getHeader(HEADER);
    return (header != null && !header.isBlank()) ? header : UUID.randomUUID().toString();
  }
}
