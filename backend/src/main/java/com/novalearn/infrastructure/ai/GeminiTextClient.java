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
 * Real Google Gemini API client (the generativelanguage.googleapis.com REST endpoint) — an
 * alternative to {@link AnthropicTextClient} for a genuinely free-tier-eligible provider. Only
 * constructed by {@code AiConfig} when {@code GEMINI_API_KEY} is set and {@code
 * ANTHROPIC_API_KEY} is not (Anthropic takes precedence when both are configured). Note: Google's
 * free tier uses submitted content to improve their products — this adapter is a reasonable
 * choice for local testing/demos, not for real children's data in a production deployment unless
 * that trade-off has been explicitly accepted; see docs/RISKS_AND_TRADEOFFS.md.
 */
public final class GeminiTextClient implements AiTextClient {

  private static final String MODEL = "gemini-2.5-flash";

  private final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
  private final String apiKey;

  public GeminiTextClient(String apiKey) {
    this.apiKey = apiKey;
  }

  @Override
  public String complete(String prompt) {
    String body = "{\"contents\":[{\"parts\":[{\"text\":\"" + escape(prompt) + "\"}]}],"
        + "\"generationConfig\":{\"maxOutputTokens\":300}}";
    HttpRequest request = HttpRequest.newBuilder(URI.create(
            "https://generativelanguage.googleapis.com/v1beta/models/" + MODEL + ":generateContent?key=" + apiKey))
        .header("content-type", "application/json")
        .timeout(Duration.ofSeconds(30))
        .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))
        .build();
    try {
      HttpResponse<String> response = http.send(request, HttpResponse.BodyHandlers.ofString());
      if (response.statusCode() != 200) {
        throw new IllegalStateException("Gemini API returned status " + response.statusCode());
      }
      return extractText(response.body());
    } catch (IOException | InterruptedException e) {
      if (e instanceof InterruptedException) {
        Thread.currentThread().interrupt();
      }
      throw new IllegalStateException("Gemini API call failed", e);
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
