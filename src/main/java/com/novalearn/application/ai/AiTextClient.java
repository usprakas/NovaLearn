package com.novalearn.application.ai;

/**
 * Port to a real text-generation backend. {@code com.novalearn.config.AiConfig} wires an
 * implementation only when {@code ANTHROPIC_API_KEY} is set; otherwise no bean is registered and
 * callers (via {@code Optional<AiTextClient>}) fall back to deterministic offline templates.
 */
public interface AiTextClient {
  String complete(String prompt);
}
