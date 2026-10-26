# 0003 — Riverpod for Flutter state management

## Status
Accepted and implemented, scoped to the app-wiring layer (see "Consequences" below for exactly
what did and didn't change).

## Context
The existing Flutter app (built before this master spec) uses plain `StatefulWidget` +
`FutureBuilder` throughout, with dependencies passed down the widget tree via constructor
parameters (`NovaLearnApi api`, `Session session`, etc.). This works for the app's current size but
doesn't scale cleanly as more screens need to share state (e.g. the selected child, auth session,
and cached lesson list are each currently re-fetched or re-threaded per screen).

The master spec asks for "a maintainable state-management solution, such as Riverpod" and to
document the choice.

## Decision
Adopt Riverpod. Reasons over the alternatives:
- **vs. plain `Provider`**: Riverpod is compile-time safe (no `BuildContext` lookup that can fail
  at runtime if a provider isn't found above in the tree) and doesn't require wrapping widgets in
  `BuildContext`-dependent lookups, which matters once the tutor/homework/dashboard screens need to
  share the selected-child state that `ChildPicker` currently owns locally.
- **vs. Bloc**: Bloc's event/state boilerplate is heavier than this app's current complexity
  justifies; Riverpod's providers map more directly onto the existing repository-interface pattern
  (`AuthRepository`, `LessonsRepository`, etc. each become a provider).
- **vs. leaving it as-is**: plain `StatefulWidget` already shows strain (session/auth state is
  manually threaded through `app.dart` -> `HomeScreen` -> every tab), and every new Phase 3 screen
  adds to that.

## Consequences (actual, as implemented)
- `NovaLearnApi` and `SessionStore` are now `Provider`s (`core/providers.dart`); `SessionController`
  (a `StateNotifier<AsyncValue<Session?>>`) owns restore/login/register/sign-out and is exposed via
  `sessionControllerProvider`. `app.dart` and `AuthScreen` became `ConsumerWidget`/
  `ConsumerStatefulWidget`, reading that provider instead of receiving a `Session`/`NovaLearnApi`/
  `onAuthenticated` callback via constructor.
- **Deliberately not migrated**: `HomeScreen` still resolves `token`/`api` once (from the session
  state and `novaLearnApiProvider`) and passes them down to `LessonListTab`, `TutorTab`,
  `HomeworkTab`, and `ParentDashboard` via constructor parameters, same as before Riverpod. Those
  widgets each have a narrow, already-clean dependency list; converting them to read providers
  directly would be churn without fixing anything real. If a future screen needs state shared
  *across* those tabs (not just within one), that's the trigger to extend Riverpod further, not a
  blanket "convert everything" pass.
- `widget_test.dart` now wraps `AuthScreen` in a `ProviderScope` with
  `sessionControllerProvider.overrideWith(...)`, using a real `SessionController` backed by a fake
  `AuthRepository` and an inert `SessionStore` subclass (so the test never touches the real
  `flutter_secure_storage` platform channel, which is unavailable under `flutter test`).
- `lesson_attempt_test.dart` was deleted and replaced by `lesson_test.dart` — the client-side
  `LessonAttempt`/scoring logic it tested no longer exists at all (scoring moved server-side in
  Phase 2, independent of this ADR), so there was nothing left to port forward.
