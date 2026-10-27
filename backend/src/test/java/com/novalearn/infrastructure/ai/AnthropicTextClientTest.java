package com.novalearn.infrastructure.ai;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class AnthropicTextClientTest {

  private final AnthropicTextClient client = new AnthropicTextClient("unused-in-this-test");

  @Test
  void decodesEscapedNewlinesAndQuotesInsteadOfLeavingThemLiteral() {
    String responseBody = "{\"content\":[{\"type\":\"text\",\"text\":"
        + "\"Line one.\\nLine two says \\\"hello\\\".\"}]}";

    String result = client.extractText(responseBody);

    assertThat(result).isEqualTo("Line one.\nLine two says \"hello\".");
  }

  @Test
  void doesNotStopEarlyAtAnEscapedQuoteInsideTheResponseText() {
    String responseBody = "{\"content\":[{\"type\":\"text\",\"text\":"
        + "\"The dog said \\\"woof\\\" and then kept running.\"}]}";

    String result = client.extractText(responseBody);

    assertThat(result).isEqualTo("The dog said \"woof\" and then kept running.");
  }

  @Test
  void returnsTheRawBodyWhenNoTextFieldIsFound() {
    String responseBody = "{\"error\":\"nope\"}";

    assertThat(client.extractText(responseBody)).isEqualTo(responseBody);
  }
}
