import 'dart:typed_data';
import 'homework_guidance.dart';

abstract interface class HomeworkRepository {
  Future<HomeworkGuidance> explain(String token, String childId, String questionText);

  /// Reads the homework question off a worksheet photo. Returns the transcribed text for the user
  /// to check and edit before calling [explain] — it is not submitted automatically.
  Future<String> scanQuestion(String token, String childId, Uint8List imageBytes);
}
