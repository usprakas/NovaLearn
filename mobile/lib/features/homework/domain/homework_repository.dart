import 'homework_guidance.dart';

abstract interface class HomeworkRepository {
  Future<HomeworkGuidance> explain(String token, String childId, String questionText);
}
