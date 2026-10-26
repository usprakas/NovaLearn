import 'package:flutter/material.dart';
import '../../children/domain/child.dart';
import '../../rewards/domain/badges_repository.dart';
import '../../rewards/domain/child_badge.dart';
import '../domain/child_dashboard.dart';
import '../domain/dashboard_repository.dart';
import '../domain/progress.dart';
import '../domain/progress_repository.dart';

class ParentDashboard extends StatelessWidget {
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
  Widget build(BuildContext context) => FutureBuilder<
      (ChildDashboard, List<LessonProgress>, List<ChildBadge>)>(
      future: _load(),
      builder: (BuildContext context,
          AsyncSnapshot<(ChildDashboard, List<LessonProgress>, List<ChildBadge>)> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Unable to load progress: ${snapshot.error}'));
        }
        final ChildDashboard dashboard = snapshot.data!.$1;
        final List<LessonProgress> progress = snapshot.data!.$2;
        final List<ChildBadge> badges = snapshot.data!.$3;
        return ListView(padding: const EdgeInsets.all(24), children: <Widget>[
          Text("${child.displayName}'s progress",
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
                    color: const Color(0xff16a34a))),
          ]),
          const SizedBox(height: 12),
          Row(children: <Widget>[
            Expanded(
                child: _Metric(
                    label: 'Coins',
                    value: '${dashboard.coins}',
                    icon: Icons.stars_rounded,
                    color: const Color(0xffd97706))),
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
                children: badges
                    .map((ChildBadge badge) => Chip(
                        avatar: const Icon(Icons.emoji_events, size: 18),
                        label: Text(badge.badgeCode.replaceAll('_', ' '))))
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
                          ? Icons.check_circle
                          : Icons.hourglass_empty,
                      color: item.completed ? Colors.green : null),
                  title: Text(item.lessonCode),
                  trailing: Text('${item.score}%')))),
        ]);
      });

  Future<(ChildDashboard, List<LessonProgress>, List<ChildBadge>)> _load() async {
    final ChildDashboard dashboard = await dashboardRepository.dashboard(token, child.id);
    final List<LessonProgress> progress = await progressRepository.progress(token, child.id);
    final List<ChildBadge> badges = await badgesRepository.badges(token, child.id);
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
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Icon(icon, size: 18, color: color)),
                const SizedBox(height: 10),
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
                Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ])));
}
