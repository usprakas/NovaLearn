import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/choice_visual.dart';
import '../../../core/widgets/coordinate_grid.dart';
import '../../../core/widgets/nova_star.dart';
import '../../children/domain/child.dart';
import '../domain/exercise_evaluation.dart';
import '../domain/exercise_repository.dart';
import '../domain/lesson.dart';

/// Grade 3's "the long hand points to the N" minute-hand exercises describe a clock verbally with
/// no image — this pulls the number straight out of the existing prompt text so a clock face can
/// be drawn above the question (hour hand faint/irrelevant, long hand at that position).
final RegExp _minuteHandPattern = RegExp(r'long hand points to the (\d+)');

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
      if (evaluation.correct) {
        _celebrationPhrase = _celebrations[_celebrationRandom.nextInt(_celebrations.length)];
      }
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

  /// A clock or coordinate-grid illustration of the current question itself, derived straight
  /// from its existing prompt text (no backend tagging needed for either) — null when the prompt
  /// doesn't describe anything drawable.
  Widget? _promptVisual(Color color) {
    final RegExpMatch? minuteHand = _minuteHandPattern.firstMatch(_current.prompt);
    if (minuteHand != null) {
      final int position = int.parse(minuteHand.group(1)!);
      return ClockFaceIcon(hour: 12, minute: position * 5, size: 96, color: color, emphasizeMinuteHand: true);
    }
    final List<Offset> points = extractPlanePoints(_current.prompt);
    if (points.isNotEmpty) return CoordinateGrid(points: points, color: color);
    return null;
  }

  static const List<String> _celebrations = <String>[
    'Correct! You nailed it! ✦',
    "Yes! That's it!",
    'Nova-powered thinking!',
    'Great job — on to the next one!',
  ];

  final math.Random _celebrationRandom = math.Random();

  /// Re-rolled once per correct submission (in [_submit]), not per rebuild, so the phrase stays
  /// put while the feedback card is already showing instead of changing on every repaint.
  String _celebrationPhrase = _celebrations.first;

  String _celebration() => _celebrationPhrase;

  /// The correct answer's own picture, parsed from `ExerciseEvaluation.correctChoiceText` — sent
  /// by the server only after grading, so this never lets the client see an answer in advance.
  ParsedChoiceVisual? _correctChoiceVisual() {
    final String? text = _evaluation?.correctChoiceText;
    return text == null ? null : parseChoiceVisual(text);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int total = widget.lesson.exercises.length;
    final Widget? promptVisual = _promptVisual(scheme.primary);
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    final Duration transitionDuration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 380);
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
                        Text(_current.prompt,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontSize: 26, height: 1.25)),
                        if (promptVisual != null) ...<Widget>[
                          const SizedBox(height: 12),
                          Center(child: promptVisual),
                        ],
                        const SizedBox(height: 4),
                        RadioGroup<int>(
                            groupValue: _selectedChoice,
                            onChanged: (int? value) {
                              if (_evaluation == null) setState(() => _selectedChoice = value);
                            },
                            child: Column(
                                children: List<Widget>.generate(_current.choices.length, (int choice) {
                              final bool selected = _selectedChoice == choice;
                              final ParsedChoiceVisual? visual =
                                  parseChoiceVisual(_current.choices[choice]);
                              final TextStyle labelStyle = TextStyle(
                                  fontSize: 19,
                                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600);
                              return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Material(
                                      color: selected
                                          ? scheme.primaryContainer
                                          : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(14),
                                      child: RadioListTile<int>(
                                          contentPadding:
                                              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14)),
                                          title: visual == null
                                              ? Text(_current.choices[choice], style: labelStyle)
                                              : Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                                                  ChoiceVisualIcon(visual: visual, color: scheme.primary),
                                                  const SizedBox(width: 12),
                                                  Text(visual.label, style: labelStyle),
                                                ]),
                                          value: choice)));
                            })))
                      ]))),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: transitionDuration,
            switchInCurve: _evaluation?.correct == true ? Curves.elasticOut : Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (Widget child, Animation<double> animation) =>
                FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
            child: _evaluation == null
                ? KeyedSubtree(
                    key: const ValueKey<String>('submit'),
                    child: FilledButton(
                        onPressed: _selectedChoice == null || _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox.square(
                                dimension: 20,
                                child:
                                    CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text('Submit answer')))
                : KeyedSubtree(
                    key: ValueKey<ExerciseEvaluation>(_evaluation!),
                    child: _buildFeedback(context, scheme, reduceMotion)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback(BuildContext context, ColorScheme scheme, bool reduceMotion) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      _ShakeOnMount(
          enabled: !reduceMotion && !_evaluation!.correct,
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: _evaluation!.correct
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[AppTheme.starYellow, AppTheme.novaOrange])
                    : null,
                color: _evaluation!.correct ? null : scheme.errorContainer,
              ),
              child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _evaluation!.correct
                            ? const NovaStar(size: 30, color: AppTheme.deepSpace)
                            : Icon(Icons.lightbulb_rounded, color: scheme.onErrorContainer),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      _evaluation!.correct
                                          ? _celebration()
                                          : "Not quite — let's see why",
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: _evaluation!.correct
                                              ? AppTheme.deepSpace
                                              : scheme.onErrorContainer)),
                                  const SizedBox(height: 6),
                                  Text(_evaluation!.explanation,
                                      style: const TextStyle(fontSize: 17, height: 1.3)),
                                  if (_evaluation!.hint != null) ...<Widget>[
                                    const SizedBox(height: 8),
                                    Text('Hint: ${_evaluation!.hint}',
                                        style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                  if (_correctChoiceVisual() != null) ...<Widget>[
                                    const SizedBox(height: 12),
                                    Row(children: <Widget>[
                                      ChoiceVisualIcon(
                                          visual: _correctChoiceVisual()!,
                                          size: 36,
                                          color: _evaluation!.correct
                                              ? scheme.onPrimaryContainer
                                              : scheme.onErrorContainer),
                                      const SizedBox(width: 10),
                                      Text('The answer: ${_correctChoiceVisual()!.label}',
                                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                              color: _evaluation!.correct
                                                  ? scheme.onPrimaryContainer
                                                  : scheme.onErrorContainer)),
                                    ]),
                                  ],
                                ])),
                      ])))),
      const SizedBox(height: 12),
      FilledButton(
          onPressed: _next, child: Text(_isLast ? 'Finish lesson' : 'Next question')),
    ]);
  }
}

/// A brief, gentle horizontal shake on mount — used only for a wrong answer, and only when
/// [enabled] (i.e. the OS's reduce-motion setting isn't on). Small amplitude by design: this is
/// meant to read as "hm, not quite," not as a punishing or alarming effect for a young child.
class _ShakeOnMount extends StatefulWidget {
  const _ShakeOnMount({required this.enabled, required this.child});
  final bool enabled;
  final Widget child;

  @override
  State<_ShakeOnMount> createState() => _ShakeOnMountState();
}

class _ShakeOnMountState extends State<_ShakeOnMount> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
  late final Animation<double> _offset = TweenSequence<double>(<TweenSequenceItem<double>>[
    TweenSequenceItem<double>(tween: Tween<double>(begin: 0, end: -8), weight: 1),
    TweenSequenceItem<double>(tween: Tween<double>(begin: -8, end: 6), weight: 1),
    TweenSequenceItem<double>(tween: Tween<double>(begin: 6, end: -4), weight: 1),
    TweenSequenceItem<double>(tween: Tween<double>(begin: -4, end: 0), weight: 1),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
        animation: _offset,
        builder: (BuildContext context, Widget? child) =>
            Transform.translate(offset: Offset(_offset.value, 0), child: child),
        child: widget.child);
  }
}
