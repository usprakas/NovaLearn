import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novalearn_mobile/app.dart';
import 'package:novalearn_mobile/core/security/session_store.dart';
import 'package:novalearn_mobile/features/auth/application/session_controller.dart';
import 'package:novalearn_mobile/features/auth/domain/auth_repository.dart';
import 'package:novalearn_mobile/features/auth/presentation/auth_screen.dart';
import 'package:novalearn_mobile/features/landing/presentation/landing_screen.dart';

class _StubAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> login(String email, String password) async =>
      const AuthSession(accessToken: 'token', refreshToken: 'refresh-token', email: 'demo@novalearn.app');

  @override
  Future<AuthSession> register(String email, String password) async =>
      const AuthSession(accessToken: 'token', refreshToken: 'refresh-token', email: 'demo@novalearn.app');

  @override
  Future<AuthSession> refresh(String refreshToken) async =>
      const AuthSession(accessToken: 'token', refreshToken: 'refresh-token', email: 'demo@novalearn.app');

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<void> deleteAccount(String accessToken, String password) async {}
}

class _InertSessionStore extends SessionStore {
  @override
  Future<Session?> read() async => null;

  @override
  Future<void> save(Session session) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  testWidgets(
      'landing -> sign-in -> logged-in actually changes what is on screen at each step',
      (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        sessionControllerProvider.overrideWith(
            (ref) => SessionController(_StubAuthRepository(), _InertSessionStore())),
      ],
      child: const NovaLearnApp(),
    ));
    await tester.pump();

    // Starts on the landing page, not straight on a login form. (The tagline text is
    // deliberately NOT used to distinguish these two screens — AuthScreen has its own copy of it
    // in its own hero section, left over from before the landing page existed.)
    expect(find.byType(LandingScreen), findsOneWidget);
    expect(find.byType(AuthScreen), findsNothing);

    await tester.ensureVisible(find.text('Get started').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started').first);
    await tester.pumpAndSettle();

    // "Get started" reveals the sign-in form in place, replacing the landing page outright —
    // not a route pushed on top of it, which is exactly the bug this test guards against: a
    // pushed AuthScreen never reacts to the session-based screen swap underneath it once login
    // succeeds.
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.byType(LandingScreen), findsNothing);

    await tester.ensureVisible(find.text('Try the demo — no sign-up needed'));
    await tester.tap(find.text('Try the demo — no sign-up needed'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // A successful login must navigate away from the sign-in form.
    expect(find.byType(AuthScreen), findsNothing);
  });
}
