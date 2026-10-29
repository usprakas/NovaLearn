import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/security/session_store.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/session_controller.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/landing/presentation/landing_screen.dart';

class NovaLearnApp extends StatelessWidget {
  const NovaLearnApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NovaLearn',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        // `home:` is a single, never-changing widget reference across every MaterialApp rebuild
        // — _RootScreen itself does the conditional swap internally. Confirmed by testing (not
        // just suspected) that having `home:` itself evaluate to a *different* widget value on
        // each rebuild doesn't cleanly replace the active route the way it looks like it should:
        // the previous content stays mounted underneath rather than being torn down, so a login
        // could "succeed" and nothing would ever appear to happen on screen. Keeping `home:`
        // stable and doing the swap inside one widget's own build() is normal, well-understood
        // widget-tree reconciliation — no route-level ambiguity at all.
        home: const _RootScreen(),
      );
}

class _RootScreen extends ConsumerStatefulWidget {
  const _RootScreen();

  @override
  ConsumerState<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<_RootScreen> {
  bool _showAuthForm = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Session?> sessionState = ref.watch(sessionControllerProvider);
    return sessionState.when(
      data: (Session? session) => session != null
          ? HomeScreen(session: session)
          : _showAuthForm
              ? const AuthScreen()
              : LandingScreen(onGetStarted: () => setState(() => _showAuthForm = true)),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (Object error, StackTrace stackTrace) => Scaffold(
          body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                            "NovaLearn couldn't restore your session.",
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        FilledButton(
                            onPressed: () =>
                                ref.read(sessionControllerProvider.notifier).signOut(),
                            child: const Text('Continue to sign in')),
                      ])))),
    );
  }
}
