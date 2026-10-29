import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_state.dart';
import '../../children/domain/child.dart';
import '../../rewards/domain/badges_repository.dart';
import '../../rewards/domain/child_badge.dart';
import '../domain/child_dashboard.dart';
import '../domain/dashboard_repository.dart';
import '../domain/progress.dart';
import '../domain/progress_repository.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({
    super.key,
    required this.token,
    required this.child,
    required this.dashboardRepository,
    required this.progressRepository,
    required this.badgesRepository,
  });
  final String token;
  final Child child;
  final DashboardRepository dashboardRepository;
  final ProgressRepository progressRepository;
  final BadgesRepository badgesRepository;

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

typedef _DashboardData = (ChildDashboard, List<LessonProgress>, List<ChildBadge>);

class _ParentDashboardState extends State<ParentDashboard> {
  late Future<_DashboardData> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  void _reload() => setState(() => _data = _load());

  @override
  Widget build(BuildContext context) => FutureBuilder<_DashboardData>(
      future: _data,
      builder: (BuildContext context, AsyncSnapshot<_DashboardData> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorState(
              message: friendlyErrorMessage(snapshot.error!), onRetry: _reload);
        }
        final ChildDashboard dashboard = snapshot.data!.$1;
        final List<LessonProgress> progress = snapshot.data!.$2;
        final List<ChildBadge> badges = snapshot.data!.$3;
        return ListView(padding: const EdgeInsets.all(24), children: <Widget>[
          Text("${widget.child.displayName}'s progress",
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Row(children: <Widget>[
            Expanded(
                child: _Metric(
                    label: 'This week',
                    value: '${dashboard.lessonsCompletedThisWeek}',
                    icon: Icons.calendar_today_rounded,
                    color: const Color(0xff2563eb))),
            const SizedBox(width: 12),
            Expanded(
                child: _Metric(
                    label: 'Average score',
                    value: '${dashboard.averageScore}%',
                    icon: Icons.trending_up_rounded,
                    // Same WCAG-corrected green as AppTheme.subjectColor's ENGLISH shade.
                    color: const Color(0xff12883e))),
          ]),
          const SizedBox(height: 12),
          Row(children: <Widget>[
            Expanded(
                child: _Metric(
                    label: 'Coins',
                    value: '${dashboard.coins}',
                    icon: Icons.stars_rounded,
                    // Darkened from #d97706 — the original failed WCAG's 3:1 non-text
                    // contrast threshold even directly against the page background (2.97:1).
                    color: const Color(0xffb16105))),
            const SizedBox(width: 12),
            Expanded(
                child: _Metric(
                    label: 'Day streak',
                    value: '${dashboard.currentStreak}',
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xffdc2626))),
          ]),
          if (dashboard.strongestSubject != null) ...<Widget>[
            const SizedBox(height: 12),
            Text('Strongest subject: ${dashboard.strongestSubject}'),
            if (dashboard.weakestSubject != null &&
                dashboard.weakestSubject != dashboard.strongestSubject)
              Text('Could use more practice: ${dashboard.weakestSubject}'),
          ],
          if (dashboard.recommendedNextLessonTitle != null) ...<Widget>[
            const SizedBox(height: 12),
            Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: ListTile(
                    leading: const Icon(Icons.arrow_circle_right_outlined),
                    title: const Text('Recommended next'),
                    subtitle: Text(dashboard.recommendedNextLessonTitle!))),
          ],
          if (badges.isNotEmpty) ...<Widget>[
            const SizedBox(height: 24),
            Text('Badges earned', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: badges
                    .map((ChildBadge badge) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                              colors: <Color>[AppTheme.starYellow, AppTheme.novaOrange]),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          const Icon(Icons.emoji_events_rounded, size: 18, color: AppTheme.deepSpace),
                          const SizedBox(width: 6),
                          Text(badge.badgeCode.replaceAll('_', ' '),
                              style: const TextStyle(
                                  color: AppTheme.deepSpace, fontWeight: FontWeight.w800)),
                        ])))
                    .toList()),
          ],
          const SizedBox(height: 24),
          Text('Recent lessons', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (progress.isEmpty)
            const Card(
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Complete a lesson to see progress here.'))),
          ...progress.map((LessonProgress item) => Card(
              child: ListTile(
                  leading: Icon(
                      item.completed
                          ? Icons.check_circle_rounded
                          : Icons.hourglass_empty_rounded,
                      // Same WCAG-corrected green as AppTheme.subjectColor's ENGLISH shade.
                      color: item.completed ? const Color(0xff12883e) : null),
                  title: Text(item.lessonCode),
                  trailing: Text('${item.score}%')))),
        ]);
      });

  Future<_DashboardData> _load() async {
    final ChildDashboard dashboard =
        await widget.dashboardRepository.dashboard(widget.token, widget.child.id);
    final List<LessonProgress> progress =
        await widget.progressRepository.progress(widget.token, widget.child.id);
    final List<ChildBadge> badges =
        await widget.badgesRepository.badges(widget.token, widget.child.id);
    return (dashboard, progress, badges);
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          // Merges the value+label into one phrase for a screen reader ("25 Coins") instead of
          // two disconnected stops ("25" ... "Coins") in traversal order — the icon stays
          // unlabeled since it's decorative and the label already says what the number means.
          child: Semantics(
              label: '$value $label',
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: Icon(icon, size: 18, color: color)),
                    const SizedBox(height: 10),
                    ExcludeSemantics(
                        child: Text(value, style: Theme.of(context).textTheme.headlineSmall)),
                    ExcludeSemantics(
                        child: Text(label,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
                  ]))));
}
