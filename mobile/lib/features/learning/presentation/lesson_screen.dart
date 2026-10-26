import 'package:flutter/material.dart';
import '../../children/domain/child.dart';
import '../domain/lesson.dart';
import '../domain/progress.dart';
import '../domain/progress_repository.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.token,
    required this.child,
    required this.lesson,
    required this.progressRepository,
  });
  final String token;
  final Child child;
  final Lesson lesson;
  final ProgressRepository progressRepository;
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final LessonAttempt _attempt = LessonAttempt(widget.lesson);
  bool _saving = false;
  Future<void> _finish() async {
    if (!_attempt.isComplete) return;
    setState(() => _saving = true);
    try {
      await widget.progressRepository.recordProgress(
          widget.token,
          widget.child.id,
          LessonProgressDraft(
              lessonCode: _attempt.lesson.code,
              score: _attempt.score,
              completed: true));
      if (mounted) {
        showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
                    title: const Text('Great job!'),
                    content: Text(
                        'You got ${_attempt.correctAnswers} of ${_attempt.questionCount} correct.'),
                    actions: <Widget>[
                      FilledButton(
                          onPressed: () => Navigator.of(context).popUntil(
                              (Route<dynamic> route) => route.isFirst),
                          child: const Text('Done'))
                    ]));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(_attempt.lesson.title)),
      body: ListView(padding: const EdgeInsets.all(24), children: <Widget>[
        Text(_attempt.lesson.description,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 20),
        ...List<Widget>.generate(_attempt.questionCount, (int index) {
          final LessonQuestion q = _attempt.lesson.questions[index];
          return Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${index + 1}. ${q.prompt}',
                            style: Theme.of(context).textTheme.titleMedium),
                        RadioGroup<int>(
                            groupValue: _attempt.answerAt(index),
                            onChanged: (int? value) {
                              if (value != null) {
                                setState(() => _attempt.answer(index, value));
                              }
                            },
                            child: Column(
                                children: List<Widget>.generate(
                                    q.choices.length,
                                    (int choice) => RadioListTile<int>(
                                        title: Text(q.choices[choice]),
                                        value: choice))))
                      ])));
        }),
        const SizedBox(height: 16),
        FilledButton(
            onPressed: !_attempt.isComplete || _saving ? null : _finish,
            child: _saving
                ? const CircularProgressIndicator()
                : Text(_attempt.isComplete
                    ? 'Finish lesson'
                    : 'Answer all questions'))
      ]));
}
