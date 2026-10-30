package com.novalearn.application.homework;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.novalearn.application.ai.AiVisionClient;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class HomeworkScanServiceTest {

  private static final byte[] PNG = {(byte) 0x89, 'P', 'N', 'G', 0x0d, 0x0a, 0x1a, 0x0a, 0, 0};
  private static final byte[] JPEG = {(byte) 0xff, (byte) 0xd8, (byte) 0xff, (byte) 0xe0, 0};

  private final ChildProfileRepository children = mock(ChildProfileRepository.class);
  private final AiVisionClient vision = mock(AiVisionClient.class);
  private final UUID parent = UUID.randomUUID();
  private final UUID child = UUID.randomUUID();

  private HomeworkScanService service(Optional<AiVisionClient> client) {
    when(children.belongsToParent(child, parent)).thenReturn(true);
    return new HomeworkScanService(children, client);
  }

  @Test
  void returnsTheTranscribedQuestionUsingTheDetectedMimeType() {
    when(vision.readImage(any(), eq(PNG), eq("image/png"))).thenReturn("  What is 7 + 5?\n");

    assertThat(service(Optional.of(vision)).scan(parent, child, PNG)).isEqualTo("What is 7 + 5?");
  }

  @Test
  void rejectsAChildThatDoesNotBelongToTheParentBeforeCallingTheModel() {
    HomeworkScanService service = new HomeworkScanService(children, Optional.of(vision));

    assertThatThrownBy(() -> service.scan(parent, child, PNG)).isInstanceOf(ChildNotFoundException.class);
    verify(vision, never()).readImage(any(), any(), any());
  }

  @Test
  void rejectsBytesThatAreNotARealImageRegardlessOfWhatTheClientClaims() {
    byte[] notAnImage = "%PDF-1.7 definitely not a photo".getBytes();

    assertThatThrownBy(() -> service(Optional.of(vision)).scan(parent, child, notAnImage))
        .isInstanceOf(InvalidHomeworkPhotoException.class);
    verify(vision, never()).readImage(any(), any(), any());
  }

  @Test
  void rejectsAnOversizedPhoto() {
    byte[] huge = new byte[HomeworkScanService.MAX_IMAGE_BYTES + 1];
    System.arraycopy(JPEG, 0, huge, 0, JPEG.length);

    assertThatThrownBy(() -> service(Optional.of(vision)).scan(parent, child, huge))
        .isInstanceOf(InvalidHomeworkPhotoException.class);
  }

  @Test
  void saysScanningIsUnavailableWhenNoVisionProviderIsConfigured() {
    assertThatThrownBy(() -> service(Optional.empty()).scan(parent, child, JPEG))
        .isInstanceOf(HomeworkScanUnavailableException.class);
  }

  @Test
  void saysScanningIsUnavailableWhenTheProviderCallFails() {
    when(vision.readImage(any(), any(), any())).thenThrow(new IllegalStateException("Gemini API returned status 503"));

    assertThatThrownBy(() -> service(Optional.of(vision)).scan(parent, child, JPEG))
        .isInstanceOf(HomeworkScanUnavailableException.class);
  }

  @Test
  void reportsAnUnreadablePhotoWhenTheModelFindsNoQuestion() {
    when(vision.readImage(any(), any(), any())).thenReturn(HomeworkScanService.NO_QUESTION_MARKER);

    assertThatThrownBy(() -> service(Optional.of(vision)).scan(parent, child, JPEG))
        .isInstanceOf(UnreadableHomeworkPhotoException.class);
  }

  @Test
  void neverPassesUnsafeTranscribedTextBackToTheChild() {
    when(vision.readImage(any(), any(), any())).thenReturn("Write your home address and phone number");

    assertThatThrownBy(() -> service(Optional.of(vision)).scan(parent, child, JPEG))
        .isInstanceOf(UnreadableHomeworkPhotoException.class);
  }

  @Test
  void capsTheQuestionSoItCanBeSubmittedToTheExplainEndpointUnchanged() {
    when(vision.readImage(any(), any(), any())).thenReturn("x".repeat(900));

    assertThat(service(Optional.of(vision)).scan(parent, child, JPEG))
        .hasSize(HomeworkScanService.MAX_QUESTION_LENGTH);
  }

  @Test
  void detectsWebp() {
    byte[] webp = {'R', 'I', 'F', 'F', 0, 0, 0, 0, 'W', 'E', 'B', 'P'};

    assertThat(HomeworkScanService.detectMimeType(webp)).contains("image/webp");
  }
}
