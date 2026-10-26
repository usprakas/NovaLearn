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
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int total = widget.lesson.exercises.length;
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                          value: (_index + 1) / total,
                          minHeight: 8,
                          backgroundColor: scheme.surfaceContainerHighest))),
              const SizedBox(width: 12),
              Text('${_index + 1} / $total',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 20),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_current.prompt, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        RadioGroup<int>(
                            groupValue: _selectedChoice,
                            onChanged: (int? value) {
                              if (_evaluation == null) setState(() => _selectedChoice = value);
                            },
                            child: Column(
                                children: List<Widget>.generate(_current.choices.length, (int choice) {
                              final bool selected = _selectedChoice == choice;
                              return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Material(
                                      color: selected
                                          ? scheme.primaryContainer
                                          : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(14),
                                      child: RadioListTile<int>(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14)),
                                          title: Text(_current.choices[choice],
                                              style: TextStyle(
                                                  fontWeight: selected
                                                      ? FontWeight.w700
                                                      : FontWeight.w500)),
                                          value: choice)));
                            })))
                      ]))),
          const SizedBox(height: 20),
          if (_evaluation == null)
            FilledButton(
                onPressed: _selectedChoice == null || _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Submit answer'))
          else ...<Widget>[
            Card(
                color: _evaluation!.correct ? scheme.primaryContainer : scheme.errorContainer,
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                              _evaluation!.correct
                                  ? Icons.check_circle_rounded
                                  : Icons.lightbulb_rounded,
                              color: _evaluation!.correct
                                  ? scheme.onPrimaryContainer
                                  : scheme.onErrorContainer),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(_evaluation!.correct ? 'Correct!' : 'Not quite',
                                        style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 6),
                                    Text(_evaluation!.explanation),
                                    if (_evaluation!.hint != null) ...<Widget>[
                                      const SizedBox(height: 8),
                                      Text('Hint: ${_evaluation!.hint}',
                                          style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ])),
                        ]))),
            const SizedBox(height: 12),
            FilledButton(
                onPressed: _next,
                child: Text(_isLast ? 'Finish lesson' : 'Next question')),
          ],
        ],
      ),
    );
  }
}
