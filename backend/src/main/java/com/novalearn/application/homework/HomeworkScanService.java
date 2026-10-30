package com.novalearn.application.homework;

import com.novalearn.application.ai.AiVisionClient;
import com.novalearn.application.ai.ContentSafetyFilter;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import java.util.Optional;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Reads a homework question off a photo of a worksheet. Deliberately only a transcription step:
 * the extracted text goes back to the client to be checked/edited, then submitted through {@link
 * HomeworkService#explain} like a typed question, so the same input validation and content-safety
 * treatment apply and a person confirms what the model read. The photo is never stored or logged —
 * it exists only in memory for the duration of this call. See docs/SECURITY_AND_CHILD_SAFETY.md.
 */
@Service
public class HomeworkScanService {

  /** Matches {@code ExplainHomeworkRequest}'s cap, so a scanned question can be submitted as-is. */
  public static final int MAX_QUESTION_LENGTH = 500;
  public static final int MAX_IMAGE_BYTES = 5 * 1024 * 1024;
  static final String NO_QUESTION_MARKER = "NO_QUESTION";

  private final ChildProfileRepository children;
  private final Optional<AiVisionClient> visionClient;

  public HomeworkScanService(ChildProfileRepository children, Optional<AiVisionClient> visionClient) {
    this.children = children;
    this.visionClient = visionClient;
  }

  @Transactional(readOnly = true)
  public String scan(UUID parentId, UUID childId, byte[] image) {
    if (!children.belongsToParent(childId, parentId)) {
      throw new ChildNotFoundException();
    }
    if (image == null || image.length == 0) {
      throw new InvalidHomeworkPhotoException("A photo is required");
    }
    if (image.length > MAX_IMAGE_BYTES) {
      throw new InvalidHomeworkPhotoException("That photo is too large (max 5 MB)");
    }
    String mimeType = detectMimeType(image)
        .orElseThrow(() -> new InvalidHomeworkPhotoException("Please upload a JPEG, PNG, or WebP photo"));
    AiVisionClient client = visionClient.orElseThrow(HomeworkScanUnavailableException::new);

    String raw;
    try {
      raw = client.readImage(PROMPT, image, mimeType);
    } catch (RuntimeException visionCallFailed) {
      throw new HomeworkScanUnavailableException();
    }
    String question = raw == null ? "" : raw.trim();
    if (question.isEmpty() || question.contains(NO_QUESTION_MARKER) || !ContentSafetyFilter.isSafe(question)) {
      throw new UnreadableHomeworkPhotoException();
    }
    return question.length() > MAX_QUESTION_LENGTH ? question.substring(0, MAX_QUESTION_LENGTH).trim() : question;
  }

  /** Detected from the file's own leading bytes, never from a client-declared content type. */
  static Optional<String> detectMimeType(byte[] b) {
    if (b.length >= 3 && (b[0] & 0xff) == 0xff && (b[1] & 0xff) == 0xd8 && (b[2] & 0xff) == 0xff) {
      return Optional.of("image/jpeg");
    }
    if (b.length >= 8 && (b[0] & 0xff) == 0x89 && b[1] == 'P' && b[2] == 'N' && b[3] == 'G') {
      return Optional.of("image/png");
    }
    if (b.length >= 12 && b[0] == 'R' && b[1] == 'I' && b[2] == 'F' && b[3] == 'F'
        && b[8] == 'W' && b[9] == 'E' && b[10] == 'B' && b[11] == 'P') {
      return Optional.of("image/webp");
    }
    return Optional.empty();
  }

  private static final String PROMPT =
      "This is a photo of a child's homework worksheet (Pre-K to Grade 6). Transcribe ONLY the "
      + "homework question or problem text, exactly as written, so it can be typed into a "
      + "homework helper. If several questions are visible, transcribe only the most prominent "
      + "one. Write math using plain characters (e.g. 7 + 5 = ?, 3/4, 2 x 6). Do not solve it, "
      + "do not add commentary, and leave out any names, school names, or other personal "
      + "details. Plain text only, no markdown. If the photo does not show a homework question, "
      + "reply with exactly " + NO_QUESTION_MARKER + ".";
}
