import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novalearn_mobile/core/security/session_store.dart';
import 'package:novalearn_mobile/features/auth/application/session_controller.dart';
import 'package:novalearn_mobile/features/auth/domain/auth_repository.dart';
import 'package:novalearn_mobile/features/auth/presentation/auth_screen.dart';

class _StubAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> login(String email, String password) async =>
      const AuthSession(accessToken: 'token', refreshToken: 'refresh-token', email: 'parent@example.com');

  @override
  Future<AuthSession> register(String email, String password) async =>
      const AuthSession(accessToken: 'token', refreshToken: 'refresh-token', email: 'parent@example.com');

  @override
  Future<AuthSession> refresh(String refreshToken) async =>
      const AuthSession(accessToken: 'token', refreshToken: 'refresh-token', email: 'parent@example.com');

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<void> deleteAccount(String accessToken, String password) async {}
}

/// Avoids touching the real `flutter_secure_storage` platform channel, which is unavailable
/// under `flutter test`.
class _InertSessionStore extends SessionStore {
  @override
  Future<Session?> read() async => null;

  @override
  Future<void> save(Session session) async {}

  @override
  Future<void> clear() async {}
}

Widget _authScreenUnderTest() => ProviderScope(
      overrides: <Override>[
        sessionControllerProvider.overrideWith(
            (ref) => SessionController(_StubAuthRepository(), _InertSessionStore())),
      ],
      child: const MaterialApp(home: AuthScreen()),
    );

void main() {
  testWidgets('shows the NovaLearn sign-in form with email and password fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(_authScreenUnderTest());

    expect(find.text('NovaLearn'), findsOneWidget);
    expect(find.text('Welcome back, parent!'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('switches to the registration form', (WidgetTester tester) async {
    await tester.pumpWidget(_authScreenUnderTest());

    // The hero section pushes the toggle button below the fold on a small test viewport — scroll
    // it into view first, same as a real (narrow) phone screen would need to.
    await tester.ensureVisible(find.text('New to NovaLearn? Create an account'));
    await tester.tap(find.text('New to NovaLearn? Create an account'));
    await tester.pump();

    expect(find.text('Create your parent account'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Create account'), findsOneWidget);
  });
}
