import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_state.dart';
import '../../children/domain/child.dart';
import '../domain/exercise_repository.dart';
import '../domain/lesson.dart';
import '../domain/lessons_repository.dart';
import 'lesson_screen.dart';

class LessonListTab extends StatefulWidget {
  const LessonListTab({
    super.key,
    required this.token,
    required this.child,
    required this.lessonsRepository,
    required this.exerciseRepository,
    required this.onLessonCompleted,
  });
  final String token;
  final Child child;
  final LessonsRepository lessonsRepository;
  final ExerciseRepository exerciseRepository;
  final VoidCallback onLessonCompleted;

  @override
  State<LessonListTab> createState() => _LessonListTabState();
}

class _LessonListTabState extends State<LessonListTab> {
  late Future<List<LessonSummary>> _lessons;

  @override
  void initState() {
    super.initState();
    _lessons = widget.lessonsRepository.lessons(widget.token, widget.child.id);
  }

  void _reload() => setState(
      () => _lessons = widget.lessonsRepository.lessons(widget.token, widget.child.id));

  Future<void> _openLesson(LessonSummary summary) async {
    final Lesson lesson =
        await widget.lessonsRepository.lesson(widget.token, summary.code);
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => LessonScreen(
            token: widget.token,
            child: widget.child,
            lesson: lesson,
            exerciseRepository: widget.exerciseRepository)));
    widget.onLessonCompleted();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<LessonSummary>>(
      future: _lessons,
      builder: (BuildContext context, AsyncSnapshot<List<LessonSummary>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorState(
              message: friendlyErrorMessage(snapshot.error!), onRetry: _reload);
        }
        final List<LessonSummary> lessons = snapshot.data ?? <LessonSummary>[];
        return ListView(padding: const EdgeInsets.all(24), children: <Widget>[
          Text('Hi, ${widget.child.displayName}!',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text("Ready for today's learning adventure?",
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          ...lessons.map((LessonSummary summary) {
            final Color subjectColor = AppTheme.subjectColor(context, summary.subject);
            return Card(
                child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: subjectColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle),
                        child: Icon(AppTheme.subjectIcon(summary.subject),
                            color: subjectColor)),
                    title: Text(summary.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(summary.description),
                    trailing: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            shape: BoxShape.circle),
                        child: Icon(Icons.play_arrow,
                            color: Theme.of(context).colorScheme.onPrimaryContainer, size: 20)),
                    onTap: () => _openLesson(summary)));
          }),
        ]);
      });
}
