package com.novalearn.config;

import com.novalearn.application.ai.AiTextClient;
import com.novalearn.application.ai.AiVisionClient;
import com.novalearn.infrastructure.ai.AnthropicTextClient;
import com.novalearn.infrastructure.ai.GeminiTextClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Registers a real {@link AiTextClient} bean only when a provider key is set — {@code
 * ANTHROPIC_API_KEY} takes precedence if both are configured, falling back to {@code
 * GEMINI_API_KEY}. A null return here is a supported Spring pattern: it is exposed to consumers
 * as {@code Optional<AiTextClient>}, so the tutor and homework-helper services fall back to their
 * deterministic offline templates when neither key is provisioned.
 */
@Configuration
public class AiConfig {
  @Bean
  public AiTextClient aiTextClient() {
    String anthropicKey = System.getenv("ANTHROPIC_API_KEY");
    if (anthropicKey != null && !anthropicKey.isBlank()) {
      return new AnthropicTextClient(anthropicKey);
    }
    String geminiKey = System.getenv("GEMINI_API_KEY");
    if (geminiKey != null && !geminiKey.isBlank()) {
      return new GeminiTextClient(geminiKey);
    }
    return null;
  }

  /**
   * Homework photo scanning. Only Gemini is wired for images today, so this is registered
   * whenever {@code GEMINI_API_KEY} is set — independently of which provider handles text. With no
   * key, no bean is registered and the scan endpoint answers 503 "please type it instead".
   */
  @Bean
  public AiVisionClient aiVisionClient() {
    String geminiKey = System.getenv("GEMINI_API_KEY");
    if (geminiKey != null && !geminiKey.isBlank()) {
      return new GeminiTextClient(geminiKey)::readImage;
    }
    return null;
  }
}
