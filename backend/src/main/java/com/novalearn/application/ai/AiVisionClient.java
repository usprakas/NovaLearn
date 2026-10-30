package com.novalearn.application.ai;

/**
 * Port to a real image-understanding backend, used to read a homework question off a photo.
 * {@code com.novalearn.config.AiConfig} wires an implementation only when a vision-capable
 * provider key is set; otherwise no bean is registered and callers (via {@code
 * Optional<AiVisionClient>}) tell the user to type the question instead — there is no meaningful
 * deterministic offline fallback for reading a photo.
 */
public interface AiVisionClient {
  /**
   * @param image raw image bytes (already validated as JPEG, PNG, or WebP)
   * @param mimeType the image's real MIME type, detected from its bytes
   */
  String readImage(String prompt, byte[] image, String mimeType);
}
