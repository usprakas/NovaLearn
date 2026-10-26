package com.novalearn.config;

import com.novalearn.application.ai.AiTextClient;
import com.novalearn.infrastructure.ai.AnthropicTextClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Registers a real {@link AiTextClient} bean only when {@code ANTHROPIC_API_KEY} is set. A null
 * return here is a supported Spring pattern: it is exposed to consumers as
 * {@code Optional<AiTextClient>}, so the tutor and homework-helper services fall back to their
 * deterministic offline templates when no key is provisioned.
 */
@Configuration
public class AiConfig {
  @Bean
  public AiTextClient aiTextClient() {
    String apiKey = System.getenv("ANTHROPIC_API_KEY");
    return (apiKey == null || apiKey.isBlank()) ? null : new AnthropicTextClient(apiKey);
  }
}
