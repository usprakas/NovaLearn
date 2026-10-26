package com.novalearn.infrastructure.ai;

import com.novalearn.application.ai.AiTextClient;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Real Anthropic Messages API client. Only constructed by {@code AiConfig} when
 * {@code ANTHROPIC_API_KEY} is set; not exercised by any test or by the default offline flow in
 * this environment (no key is provisioned here) — see RISKS_AND_TRADEOFFS.md.
 */
public final class AnthropicTextClient implements AiTextClient {

  private final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
  private final String apiKey;

  public AnthropicTextClient(String apiKey) {
    this.apiKey = apiKey;
  }

  @Override
  public String complete(String prompt) {
    String body = "{\"model\":\"claude-3-5-haiku-latest\",\"max_tokens\":300,\"messages\":"
        + "[{\"role\":\"user\",\"content\":\"" + escape(prompt) + "\"}]}";
    HttpRequest request = HttpRequest.newBuilder(URI.create("https://api.anthropic.com/v1/messages"))
        .header("x-api-key", apiKey)
        .header("anthropic-version", "2023-06-01")
        .header("content-type", "application/json")
        .timeout(Duration.ofSeconds(30))
        .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))
        .build();
    try {
      HttpResponse<String> response = http.send(request, HttpResponse.BodyHandlers.ofString());
      if (response.statusCode() != 200) {
        throw new IllegalStateException("Anthropic API returned status " + response.statusCode());
      }
      return extractText(response.body());
    } catch (IOException | InterruptedException e) {
      if (e instanceof InterruptedException) {
        Thread.currentThread().interrupt();
      }
      throw new IllegalStateException("Anthropic API call failed", e);
    }
  }

  private String extractText(String responseBody) {
    Matcher matcher = Pattern.compile("\"text\"\\s*:\\s*\"(.*?)\"", Pattern.DOTALL).matcher(responseBody);
    return matcher.find() ? matcher.group(1) : responseBody;
  }

  private String escape(String value) {
    return value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
  }
}
