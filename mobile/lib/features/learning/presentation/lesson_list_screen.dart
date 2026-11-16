import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/nova_star.dart';
import '../../../core/widgets/subject_mark.dart';
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

  /// The subject tile the child opened, or null while they're choosing a subject. With five
  /// subjects a grade has ~46 lessons — too many for one list — so the Learn tab starts on a
  /// grid of subject tiles and shows one subject's lessons at a time.
  String? _subject;

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

  /// Pre-K/Kindergarten/Grade 1 get a different lesson layout entirely — a handful of big,
  /// icon-led tiles instead of a scrolling list of titled rows with full-sentence descriptions.
  /// A child this age is choosing by picture and color, not reading a subtitle.
  bool get _isEarlyLearner =>
      gradeLevels.indexOf(widget.child.gradeLevel) <= gradeLevels.indexOf('GRADE_1');

  Future<void> _openLesson(LessonSummary summary) async {
    final Lesson lesson;
    try {
      lesson = await widget.lessonsRepository
          .lessonSet(widget.token, widget.child.id, summary.code);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
      }
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => LessonScreen(
            token: widget.token,
            child: widget.child,
            lesson: lesson,
            exerciseRepository: widget.exerciseRepository,
            lessonsRepository: widget.lessonsRepository)));
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
        final List<LessonSummary> allLessons = snapshot.data ?? <LessonSummary>[];
        // Subjects in the order the server sorts them (Math, English, EVS, Hindi, Telugu).
        final List<String> subjects = <String>[];
        for (final LessonSummary summary in allLessons) {
          if (!subjects.contains(summary.subject)) subjects.add(summary.subject);
        }
        // A grade with a single subject has nothing to choose between, so go straight to it.
        final String? subject = subjects.length == 1
            ? subjects.first
            : (subjects.contains(_subject) ? _subject : null);
        final List<LessonSummary> lessons = subject == null
            ? <LessonSummary>[]
            : allLessons.where((LessonSummary l) => l.subject == subject).toList();
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
          if (subject == null) ...<Widget>[
            Text('Pick a subject', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _SubjectGrid(
                subjects: subjects,
                lessonCounts: <String, int>{
                  for (final String s in subjects)
                    s: allLessons.where((LessonSummary l) => l.subject == s).length,
                },
                onTap: (String value) => setState(() => _subject = value)),
          ] else ...<Widget>[
            if (subjects.length > 1)
              _SubjectHeader(subject: subject, onBack: () => setState(() => _subject = null)),
            if (_isEarlyLearner)
            _EarlyLearnerGrid(lessons: lessons, onTap: _openLesson)
          else
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
                          alignment: Alignment.center,
                          child: SubjectMark(
                              subject: summary.subject, color: subjectColor, size: 22)),
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
          ],
        ]);
      });
}

/// A grid of big, tappable, icon-led tiles for the youngest children — a handful of large
/// choices shown at once rather than a scrolling list of rows with full-sentence subtitles,
/// matching the "few large choices, very low text density" pattern common across early-literacy
/// sites built for pre-readers. Auto-adjusts its column count to the available width so it works
/// on both a phone and a tablet/desktop browser without a fixed breakpoint.
class _EarlyLearnerGrid extends StatelessWidget {
  const _EarlyLearnerGrid({required this.lessons, required this.onTap});
  final List<LessonSummary> lessons;
  final ValueChanged<LessonSummary> onTap;

  @override
  Widget build(BuildContext context) => GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.95),
      itemCount: lessons.length,
      itemBuilder: (BuildContext context, int index) {
        final LessonSummary summary = lessons[index];
        final Color subjectColor = AppTheme.subjectColor(context, summary.subject);
        return _EarlyLearnerTile(
            title: summary.title,
            subject: summary.subject,
            color: subjectColor,
            onTap: () => onTap(summary));
      });
}

class _EarlyLearnerTile extends StatelessWidget {
  const _EarlyLearnerTile(
      {required this.title, required this.subject, required this.color, required this.onTap});
  final String title;
  final String subject;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 14),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: SubjectMark(subject: subject, color: Colors.white, size: 36)),
                    const SizedBox(height: 14),
                    Text(title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
                  ]))));
}

/// The Learn tab's front page: one big colored tile per subject, marked with the same icon or
/// script letter used on its lessons, so a pre-reader can pick "the orange अ one" by sight.
/// Column count adapts to the width (two on a phone, more on a tablet or desktop).
class _SubjectGrid extends StatelessWidget {
  const _SubjectGrid({required this.subjects, required this.lessonCounts, required this.onTap});
  final List<String> subjects;
  final Map<String, int> lessonCounts;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.95),
      itemCount: subjects.length,
      itemBuilder: (BuildContext context, int index) {
        final String subject = subjects[index];
        final Color color = AppTheme.subjectColor(context, subject);
        final int count = lessonCounts[subject] ?? 0;
        final String countLabel = count == 1 ? '1 lesson' : '$count lessons';
        return Semantics(
            button: true,
            label: '${AppTheme.subjectName(subject)}, $countLabel',
            excludeSemantics: true,
            child: Material(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => onTap(subject),
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                          Container(
                              width: 76,
                              height: 76,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 14),
                                ],
                              ),
                              child: SubjectMark(subject: subject, color: Colors.white, size: 38)),
                          const SizedBox(height: 14),
                          Text(AppTheme.subjectName(subject),
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontSize: 20, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(countLabel,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ])))));
      });
}

/// Shown above one subject's lessons: a way back to the subject tiles, and which subject this is.
class _SubjectHeader extends StatelessWidget {
  const _SubjectHeader({required this.subject, required this.onBack});
  final String subject;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final Color color = AppTheme.subjectColor(context, subject);
    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(children: <Widget>[
          TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('All subjects')),
          const Spacer(),
          Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: SubjectMark(subject: subject, color: Colors.white, size: 18)),
          const SizedBox(width: 8),
          Text(AppTheme.subjectName(subject), style: Theme.of(context).textTheme.titleLarge),
        ]));
  }
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
