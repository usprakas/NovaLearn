import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/security/session_store.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/session_controller.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/home/presentation/home_screen.dart';

class NovaLearnApp extends ConsumerWidget {
  const NovaLearnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Session?> sessionState = ref.watch(sessionControllerProvider);
    return MaterialApp(
      title: 'NovaLearn',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: sessionState.when(
        data: (Session? session) =>
            session == null ? const AuthScreen() : HomeScreen(session: session),
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
      ),
    );
  }
}
