import 'package:flutter/material.dart';
import '../../children/domain/child.dart';
import '../domain/lesson.dart';
import '../domain/lessons_repository.dart';
import '../domain/progress_repository.dart';
import 'lesson_screen.dart';

class LessonListTab extends StatefulWidget {
  const LessonListTab({
    super.key,
    required this.token,
    required this.child,
    required this.lessonsRepository,
    required this.progressRepository,
    required this.onLessonCompleted,
  });
  final String token;
  final Child child;
  final LessonsRepository lessonsRepository;
  final ProgressRepository progressRepository;
  final VoidCallback onLessonCompleted;

  @override
  State<LessonListTab> createState() => _LessonListTabState();
}

class _LessonListTabState extends State<LessonListTab> {
  late Future<List<LessonSummary>> _lessons;

  @override
  void initState() {
    super.initState();
    _lessons = widget.lessonsRepository.lessons(widget.token);
  }

  Future<void> _openLesson(LessonSummary summary) async {
    final Lesson lesson =
        await widget.lessonsRepository.lesson(widget.token, summary.code);
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => LessonScreen(
            token: widget.token,
            child: widget.child,
            lesson: lesson,
            progressRepository: widget.progressRepository)));
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
          return Center(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Could not load lessons: ${snapshot.error}')));
        }
        final List<LessonSummary> lessons = snapshot.data ?? <LessonSummary>[];
        return ListView(padding: const EdgeInsets.all(24), children: <Widget>[
          Text('Hi, ${widget.child.displayName}!',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text("Ready for today's learning adventure?"),
          const SizedBox(height: 24),
          ...lessons.map((LessonSummary summary) => Card(
              child: ListTile(
                  leading: Icon(summary.subject == 'MATH'
                      ? Icons.calculate_outlined
                      : Icons.menu_book_outlined),
                  title: Text(summary.title),
                  subtitle: Text(summary.description),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _openLesson(summary)))),
        ]);
      });
}
