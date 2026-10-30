package com.novalearn.infrastructure.ai;

import com.novalearn.application.ai.AiTextClient;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;
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
 *
 * <p>{@link #readImage} (the same model accepts inline images) backs homework photo scanning:
 * {@code AiConfig} registers it as the {@code AiVisionClient} bean via a method reference, so this
 * class itself only ever matches the {@code AiTextClient} port and the two beans never collide.
 */
public final class GeminiTextClient implements AiTextClient {

  // "latest" alias rather than a pinned version: Google has repeatedly retired dated model names
  // out from under this key during development (gemini-2.5-flash and gemini-2.0-flash both
  // returned 404 "no longer available" even though the former still appears in /v1beta/models).
  // A lite model is intentionally chosen over a full/pro model — tutor/homework responses are
  // capped at 500 output tokens for short, simple Grade 1-level explanations.
  private static final String MODEL = "gemini-flash-lite-latest";

  private static final Pattern TEXT_FIELD =
      Pattern.compile("\"text\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"", Pattern.DOTALL);

  private final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
  private final String apiKey;

  public GeminiTextClient(String apiKey) {
    this.apiKey = apiKey;
  }

  @Override
  public String complete(String prompt) {
    return extractText(generate("{\"contents\":[{\"parts\":[{\"text\":\"" + escape(prompt) + "\"}]}],"
        + "\"generationConfig\":{\"maxOutputTokens\":500}}"));
  }

  public String readImage(String prompt, byte[] image, String mimeType) {
    // Low temperature: this is transcription, not generation — the model should copy what is on
    // the page, not get creative with it.
    String responseBody = generate("{\"contents\":[{\"parts\":[{\"text\":\"" + escape(prompt) + "\"},"
        + "{\"inline_data\":{\"mime_type\":\"" + mimeType + "\",\"data\":\""
        + Base64.getEncoder().encodeToString(image) + "\"}}]}],"
        + "\"generationConfig\":{\"maxOutputTokens\":300,\"temperature\":0}}");
    // Unlike complete(), never fall back to the raw body: a safety-blocked or empty response would
    // otherwise surface as JSON in the child's question box.
    Matcher matcher = TEXT_FIELD.matcher(responseBody);
    if (!matcher.find()) {
      throw new IllegalStateException("Gemini returned no text for the image");
    }
    return unescapeJson(matcher.group(1));
  }

  private String generate(String body) {
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
      return response.body();
    } catch (IOException | InterruptedException e) {
      if (e instanceof InterruptedException) {
        Thread.currentThread().interrupt();
      }
      throw new IllegalStateException("Gemini API call failed", e);
    }
  }

  String extractText(String responseBody) {
    // (?:[^"\\]|\\.)* correctly walks past escaped quotes/backslashes inside the JSON string
    // value, unlike a naive ".*?" which stops at the first literal quote — including one that's
    // actually part of an escape sequence like \" inside the model's own response text.
    Matcher matcher = TEXT_FIELD.matcher(responseBody);
    return matcher.find() ? unescapeJson(matcher.group(1)) : responseBody;
  }

  private String escape(String value) {
    return value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
  }

  /** Reverses {@link #escape}-style JSON string escaping on a real response's text content. */
  private String unescapeJson(String value) {
    StringBuilder out = new StringBuilder(value.length());
    for (int i = 0; i < value.length(); i++) {
      char c = value.charAt(i);
      if (c == '\\' && i + 1 < value.length()) {
        char next = value.charAt(++i);
        switch (next) {
          case 'n' -> out.append('\n');
          case 'r' -> out.append('\r');
          case 't' -> out.append('\t');
          case '"' -> out.append('"');
          case '\\' -> out.append('\\');
          case '/' -> out.append('/');
          default -> out.append(next);
        }
      } else {
        out.append(c);
      }
    }
    return out.toString();
  }
}
