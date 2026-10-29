import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/nova_star.dart';

/// Shown once, immediately after a child profile is created — a brief, friendly introduction to
/// the AI tutor before landing in the lesson list, so the tutor reads as a character the child
/// has "met," not a chat box that just appears in a tab later. Purely presentational: it owns no
/// state and calls no API.
class MeetTutorScreen extends StatelessWidget {
  const MeetTutorScreen({super.key, required this.childName});
  final String childName;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppTheme.deepSpace, Color(0xff3b2a6b), AppTheme.cosmicViolet],
            ),
          ),
          child: SafeArea(
              child: NovaStarField(
                  starCount: 10,
                  child: Center(
                      child: SingleChildScrollView(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 440),
                              child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: const RadialGradient(
                                                  colors: <Color>[
                                                    AppTheme.novaOrange,
                                                    AppTheme.cosmicViolet
                                                  ],
                                                  radius: 0.85),
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                    color: AppTheme.novaOrange
                                                        .withValues(alpha: 0.5),
                                                    blurRadius: 36,
                                                    spreadRadius: 4),
                                              ],
                                            ),
                                            child: const Center(
                                                child: NovaStar(size: 56, color: Colors.white))),
                                        const SizedBox(height: 28),
                                        Text('Hi $childName, I\'m Nova!',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(color: Colors.white)),
                                        const SizedBox(height: 16),
                                        Text(
                                            "I'm your very own learning buddy. Ask me anything "
                                            "when you're stuck, and I'll explain it a different "
                                            "way until it clicks. Let's go exploring!",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    color: Colors.white.withValues(alpha: 0.88),
                                                    fontSize: 18,
                                                    height: 1.4)),
                                        const SizedBox(height: 36),
                                        FilledButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            style: FilledButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: AppTheme.cosmicViolet),
                                            child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 24),
                                                child: Text("Let's go!",
                                                    style: TextStyle(fontSize: 18)))),
                                      ])))))))));
}
