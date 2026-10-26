package com.novalearn.config;

import com.novalearn.infrastructure.logging.CorrelationIdFilter;
import com.novalearn.infrastructure.security.AiRateLimitFilter;
import com.novalearn.infrastructure.security.AuthRateLimitFilter;
import com.novalearn.infrastructure.security.JwtAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
public class SecurityConfig {

  @Bean
  SecurityFilterChain securityFilterChain(
      HttpSecurity http,
      JwtAuthenticationFilter jwt,
      AuthRateLimitFilter authRateLimit,
      AiRateLimitFilter aiRateLimit,
      CorrelationIdFilter correlationId)
      throws Exception {
    return http
        .csrf(c -> c.disable())
        .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .authorizeHttpRequests(a -> a
            .requestMatchers("/actuator/health", "/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
            .requestMatchers(HttpMethod.POST, "/api/v1/auth/**").permitAll()
            .anyRequest().hasRole("PARENT"))
        .addFilterBefore(jwt, UsernamePasswordAuthenticationFilter.class)
        .addFilterBefore(authRateLimit, JwtAuthenticationFilter.class)
        .addFilterBefore(aiRateLimit, JwtAuthenticationFilter.class)
        .addFilterBefore(correlationId, AuthRateLimitFilter.class)
        .build();
  }
}
