package com.novalearn.config;

import java.time.Instant;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import com.novalearn.infrastructure.logging.CorrelationIdFilter;
import com.novalearn.infrastructure.security.AiRateLimitFilter;
import com.novalearn.infrastructure.security.AuthRateLimitFilter;
import com.novalearn.infrastructure.security.JwtAuthenticationFilter;
import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
public class SecurityConfig {

  @Bean
  SecurityFilterChain securityFilterChain(
      HttpSecurity http,
      JwtAuthenticationFilter jwt,
      AuthRateLimitFilter authRateLimit,
      AiRateLimitFilter aiRateLimit,
      CorrelationIdFilter correlationId,
      CorsConfigurationSource corsConfigurationSource)
      throws Exception {
    return http
        .csrf(c -> c.disable())
        .cors(c -> c.configurationSource(corsConfigurationSource))
        .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .authorizeHttpRequests(a -> a
            .requestMatchers("/actuator/health", "/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
            .requestMatchers(HttpMethod.POST, "/api/v1/auth/**").permitAll()
            .anyRequest().hasRole("PARENT"))
        // A missing, expired, or invalid access token is 401, not Spring's default 403: clients
        // treat 401 as "this session is dead, refresh or sign in again". With 403 the mobile app
        // kept retrying a dead token after a returning visitor's access token expired.
        .exceptionHandling(e -> e.authenticationEntryPoint((request, response, ex) -> {
          response.setStatus(HttpStatus.UNAUTHORIZED.value());
          response.setContentType(MediaType.APPLICATION_JSON_VALUE);
          response.getWriter().write("{\"timestamp\":\"" + Instant.now() + "\",\"status\":401,"
              + "\"detail\":\"Your session has expired. Please sign in again.\"}");
        }))
        .addFilterBefore(jwt, UsernamePasswordAuthenticationFilter.class)
        .addFilterBefore(authRateLimit, JwtAuthenticationFilter.class)
        .addFilterBefore(aiRateLimit, JwtAuthenticationFilter.class)
        .addFilterBefore(correlationId, AuthRateLimitFilter.class)
        .build();
  }

  /**
   * Allowed origins come from {@code ALLOWED_ORIGINS} (comma-separated, supports {@code *}
   * wildcards — e.g. {@code http://localhost:*} for local dev, or the real frontend's origin in
   * production). Empty by default, which blocks every cross-origin browser request rather than
   * silently allowing any origin — a deployment has to opt in explicitly.
   */
  @Bean
  CorsConfigurationSource corsConfigurationSource(
      @Value("${novalearn.security.allowed-origins:}") String allowedOrigins) {
    CorsConfiguration config = new CorsConfiguration();
    List<String> origins = Arrays.stream(allowedOrigins.split(","))
        .map(String::trim)
        .filter(origin -> !origin.isEmpty())
        .toList();
    config.setAllowedOriginPatterns(origins);
    config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
    config.setAllowedHeaders(List.of("*"));
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", config);
    return source;
  }
}
