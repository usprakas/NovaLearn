import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novalearn_mobile/core/security/session_store.dart';
import 'package:novalearn_mobile/features/auth/domain/auth_repository.dart';
import 'package:novalearn_mobile/features/auth/presentation/auth_screen.dart';

class _StubAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> login(String email, String password) async =>
      const AuthSession(accessToken: 'token', email: 'parent@example.com');

  @override
  Future<AuthSession> register(String email, String password) async =>
      const AuthSession(accessToken: 'token', email: 'parent@example.com');
}

void main() {
  testWidgets('shows the NovaLearn sign-in form with email and password fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AuthScreen(
        api: _StubAuthRepository(),
        onAuthenticated: (Session session) async {},
      ),
    ));

    expect(find.text('NovaLearn'), findsOneWidget);
    expect(find.text('Welcome back, parent!'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('switches to the registration form', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AuthScreen(
        api: _StubAuthRepository(),
        onAuthenticated: (Session session) async {},
      ),
    ));

    await tester.tap(find.text('New to NovaLearn? Create an account'));
    await tester.pump();

    expect(find.text('Create your parent account'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Create account'), findsOneWidget);
  });
}
