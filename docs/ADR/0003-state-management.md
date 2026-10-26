# 0003 — Riverpod for Flutter state management (decided now, not yet implemented)

## Status
Accepted, implementation pending (Phase 3)

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
  manually threaded through `app.dart` → `HomeScreen` → every tab), and every new Phase 3 screen
  adds to that.

## Consequences (once implemented)
- `NovaLearnApi` and the session/auth state become providers (`Provider`/`NotifierProvider`),
  injected via `ConsumerWidget` instead of constructor parameters.
- Existing widget tests (`widget_test.dart`, `novalearn_api_test.dart`, `lesson_attempt_test.dart`)
  will need updating to wrap widgets in a `ProviderScope` with overridden providers for the fakes
  they already use.
- This is a genuine rewrite of the app's plumbing, not an incremental patch — it is scoped as its
  own Phase 3 unit of work, not bundled into this pass's backend-focused changes.
