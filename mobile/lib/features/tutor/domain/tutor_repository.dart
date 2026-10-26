import 'tutor_answer.dart';

abstract interface class TutorRepository {
  Future<TutorAnswer> ask(
    String token,
    String childId,
    String question,
    String? subject,
    int attempt,
  );
}
