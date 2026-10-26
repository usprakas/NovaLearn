import 'package:flutter/material.dart';
import '../../children/domain/child.dart';
import '../domain/exercise_evaluation.dart';
import '../domain/exercise_repository.dart';
import '../domain/lesson.dart';

/// Shows one exercise at a time and submits each answer to the server for grading (see
/// `ExerciseRepository.submitAnswer`) instead of computing a score locally — the client never
/// has the correct answer, so it cannot grade itself even if it wanted to.
class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.token,
    required this.child,
    required this.lesson,
    required this.exerciseRepository,
  });
  final String token;
  final Child child;
  final Lesson lesson;
  final ExerciseRepository exerciseRepository;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _index = 0;
  int? _selectedChoice;
  ExerciseEvaluation? _evaluation;
  bool _submitting = false;

  Exercise get _current => widget.lesson.exercises[_index];
  bool get _isLast => _index == widget.lesson.exercises.length - 1;

  Future<void> _submit() async {
    if (_selectedChoice == null) return;
    setState(() => _submitting = true);
    try {
      final ExerciseEvaluation evaluation = await widget.exerciseRepository.submitAnswer(
          widget.token, widget.child.id, _current.id, _selectedChoice!);
      if (mounted) setState(() => _evaluation = evaluation);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _next() {
    if (_isLast) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _index += 1;
      _selectedChoice = null;
      _evaluation = null;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Text('Question ${_index + 1} of ${widget.lesson.exercises.length}',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_current.prompt, style: Theme.of(context).textTheme.titleMedium),
                        RadioGroup<int>(
                            groupValue: _selectedChoice,
                            onChanged: (int? value) {
                              if (_evaluation == null) setState(() => _selectedChoice = value);
                            },
                            child: Column(
                                children: List<Widget>.generate(
                                    _current.choices.length,
                                    (int choice) => RadioListTile<int>(
                                        title: Text(_current.choices[choice]),
                                        value: choice))))
                      ]))),
          const SizedBox(height: 16),
          if (_evaluation == null)
            FilledButton(
                onPressed: _selectedChoice == null || _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator())
                    : const Text('Submit answer'))
          else ...<Widget>[
            Card(
                color: _evaluation!.correct
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_evaluation!.correct ? 'Correct!' : 'Not quite',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(_evaluation!.explanation),
                          if (_evaluation!.hint != null) ...<Widget>[
                            const SizedBox(height: 8),
                            Text('Hint: ${_evaluation!.hint}',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ]))),
            const SizedBox(height: 12),
            FilledButton(
                onPressed: _next,
                child: Text(_isLast ? 'Finish lesson' : 'Next question')),
          ],
        ],
      ));
}
