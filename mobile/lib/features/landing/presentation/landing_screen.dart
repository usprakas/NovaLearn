import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/nova_star.dart';

/// What a visitor sees first, before signing in — previously the app went straight from nothing
/// to the login form with no explanation of what NovaLearn even is. Purely presentational: it
/// owns no state and touches no API; [onGetStarted] is called to reveal the sign-in form, driven
/// by the caller rather than a `Navigator.push` here — see app.dart for why that distinction
/// matters (a pushed route doesn't react to the session-based screen swap underneath it).
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key, required this.onGetStarted});
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Hero(onGetStarted: onGetStarted),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('Built for how kids actually learn',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                          "Every lesson, every explanation, every picture is matched to your child's exact grade.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: const <Widget>[
                          _FeatureCard(
                              icon: Icons.school_rounded,
                              color: AppTheme.cosmicViolet,
                              title: 'Pre-K through Grade 6',
                              body:
                                  'Math and reading, leveled to each child\'s own grade — not a one-size-fits-all feed.'),
                          _FeatureCard(
                              icon: Icons.auto_awesome_rounded,
                              color: AppTheme.novaOrange,
                              title: 'A tutor that explains again, differently',
                              body:
                                  'Stuck on something? Ask again and get a new approach — a story, a real-life example, a step-by-step walkthrough.'),
                          _FeatureCard(
                              icon: Icons.insights_rounded,
                              color: AppTheme.novaPink,
                              title: 'Real progress, for parents',
                              body:
                                  'See what your child has mastered, what needs more practice, and what to try next.'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              color: scheme.surfaceContainerLow,
              child: Column(
                children: <Widget>[
                  Text('Ready when your child is.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  FilledButton(
                      onPressed: onGetStarted,
                      child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Get started'))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onGetStarted});
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) => DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppTheme.deepSpace, Color(0xff3b2a6b), AppTheme.cosmicViolet],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: NovaStarField(
          starCount: 12,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 56),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                      const NovaStar(size: 28, color: Colors.white),
                      const SizedBox(width: 10),
                      Text('NovaLearn',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white)),
                    ]),
                    const SizedBox(height: 28),
                    Text('Learning that launches curiosity.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(color: Colors.white, height: 1.15)),
                    const SizedBox(height: 16),
                    Text(
                        'An AI-guided learning companion for Pre-K through Grade 6 — math and '
                        'reading lessons, a patient tutor, and real progress parents can see.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                    const SizedBox(height: 32),
                    FilledButton(
                        onPressed: onGetStarted,
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.cosmicViolet),
                        child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Get started'))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard(
      {required this.icon, required this.color, required this.title, required this.body});
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => SizedBox(
      width: 280,
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        width: 48,
                        height: 48,
                        decoration:
                            BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: Icon(icon, color: color)),
                    const SizedBox(height: 16),
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(body,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ]))));
}
