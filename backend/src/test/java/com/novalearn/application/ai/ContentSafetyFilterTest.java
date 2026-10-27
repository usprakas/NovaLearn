package com.novalearn.application.ai;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class ContentSafetyFilterTest {

  @Test
  void leavesShortTextUntouched() {
    assertThat(ContentSafetyFilter.capLength("A short answer.")).isEqualTo("A short answer.");
  }

  @Test
  void truncatesAtTheLastSentenceBoundaryWhenOneIsCloseToTheLimit() {
    String sentence = "This is one short sentence that repeats itself over and over. ";
    String longText = sentence.repeat(30) + "This final sentence pushes it over the limit.";

    String result = ContentSafetyFilter.capLength(longText);

    assertThat(result.length()).isLessThanOrEqualTo(ContentSafetyFilter.MAX_RESPONSE_LENGTH);
    assertThat(result).endsWith(".");
    assertThat(result).doesNotEndWith("...");
  }

  @Test
  void fallsBackToAnEllipsisWhenNoSentenceBoundaryIsCloseToTheLimit() {
    String longText = "a".repeat(ContentSafetyFilter.MAX_RESPONSE_LENGTH + 500);

    String result = ContentSafetyFilter.capLength(longText);

    assertThat(result).endsWith("...");
    assertThat(result.length()).isEqualTo(ContentSafetyFilter.MAX_RESPONSE_LENGTH + 3);
  }
}
