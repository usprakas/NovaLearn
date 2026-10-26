package com.novalearn.application.ai;

import java.util.List;
import java.util.Locale;

/**
 * A minimal, keyword-based pre/post-filter for child-facing AI text. Deliberately not a
 * sophisticated classifier or a claim of comprehensive moderation — it exists to catch obviously
 * out-of-scope or unsafe content (in a child's question, or in a real model's response, which is
 * treated as untrusted input just like the question is) before anything reaches a child. See
 * docs/SECURITY_AND_CHILD_SAFETY.md for what this is and is not.
 */
public final class ContentSafetyFilter {

  private static final List<String> BLOCKED_KEYWORDS = List.of(
      "kill", "suicide", "self-harm", "self harm", "sex", "sexual", "porn",
      "drug", "drugs", "alcohol", "weapon", "gun", "knife", "bomb",
      "address", "phone number", "credit card", "social security", "password");

  public static final int MAX_RESPONSE_LENGTH = 800;

  private ContentSafetyFilter() { }

  public static boolean isSafe(String text) {
    if (text == null || text.isBlank()) {
      return true;
    }
    String lower = text.toLowerCase(Locale.ROOT);
    return BLOCKED_KEYWORDS.stream().noneMatch(lower::contains);
  }

  /** Caps response length rather than discarding an otherwise-safe answer that ran long. */
  public static String capLength(String text) {
    return text.length() <= MAX_RESPONSE_LENGTH ? text : text.substring(0, MAX_RESPONSE_LENGTH) + "...";
  }
}
