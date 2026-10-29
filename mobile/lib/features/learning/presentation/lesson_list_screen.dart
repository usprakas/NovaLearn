import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/nova_star.dart';
import '../../children/domain/child.dart';
import '../domain/child_dashboard.dart';
import '../domain/dashboard_repository.dart';
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
    required this.dashboardRepository,
    required this.onLessonCompleted,
  });
  final String token;
  final Child child;
  final LessonsRepository lessonsRepository;
  final ExerciseRepository exerciseRepository;
  final DashboardRepository dashboardRepository;
  final VoidCallback onLessonCompleted;

  @override
  State<LessonListTab> createState() => _LessonListTabState();
}

class _LessonListTabState extends State<LessonListTab> {
  late Future<List<LessonSummary>> _lessons;
  late Future<ChildDashboard> _dashboard;

  @override
  void initState() {
    super.initState();
    _lessons = widget.lessonsRepository.lessons(widget.token, widget.child.id);
    _dashboard = widget.dashboardRepository.dashboard(widget.token, widget.child.id);
  }

  void _reload() => setState(() {
        _lessons = widget.lessonsRepository.lessons(widget.token, widget.child.id);
        _dashboard = widget.dashboardRepository.dashboard(widget.token, widget.child.id);
      });

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
          Row(children: <Widget>[
            Expanded(
                child: Text('Hi, ${widget.child.displayName}!',
                    style: Theme.of(context).textTheme.headlineMedium)),
            const NovaStar(size: 26),
          ]),
          const SizedBox(height: 4),
          Text("Ready for today's learning adventure?",
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          FutureBuilder<ChildDashboard>(
            future: _dashboard,
            // The lesson list is the primary content here — if the dashboard summary fails to
            // load, show nothing extra rather than blocking or erroring the whole screen over a
            // secondary quick-glance strip.
            builder: (BuildContext context, AsyncSnapshot<ChildDashboard> snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return _QuickStats(dashboard: snapshot.data!);
            },
          ),
          const SizedBox(height: 16),
          ...lessons.map((LessonSummary summary) {
            final Color subjectColor = AppTheme.subjectColor(context, summary.subject);
            return Card(
                child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: subjectColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: subjectColor.withValues(alpha: 0.18), blurRadius: 10),
                          ],
                        ),
                        child: Icon(AppTheme.subjectIcon(summary.subject),
                            color: subjectColor, size: 22)),
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

/// A quick-glance strip of coins and streak — the numbers a child cares about most, pulled from
/// the same dashboard data the Progress tab already shows in full, surfaced here so "today's
/// adventure" opens with a sense of where they already stand instead of a cold lesson list.
class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.dashboard});
  final ChildDashboard dashboard;

  @override
  Widget build(BuildContext context) => Row(children: <Widget>[
        Expanded(
            child: _StatPill(
                icon: Icons.stars_rounded,
                // Darkened from #d97706 — the original failed WCAG's 3:1 non-text contrast
                // threshold even directly against the page background (2.97:1).
                color: const Color(0xffb16105),
                label: 'coins',
                value: '${dashboard.coins}')),
        const SizedBox(width: 12),
        Expanded(
            child: _StatPill(
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xffdc2626),
                label: 'day streak',
                value: '${dashboard.currentStreak}')),
      ]);
}

class _StatPill extends StatelessWidget {
  const _StatPill(
      {required this.icon, required this.color, required this.label, required this.value});
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18)),
      child: Semantics(
          label: '$value $label',
          child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            ExcludeSemantics(
                child: Text.rich(TextSpan(children: <InlineSpan>[
              TextSpan(
                  text: value,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w800, fontSize: 18)),
              TextSpan(
                  text: ' $label',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]))),
          ])));
}
