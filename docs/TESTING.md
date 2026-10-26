# Testing

## Backend

Commands run from `backend/`. `./mvnw clean verify` runs the full unit suite plus a PostgreSQL
Testcontainers integration test. **Docker must be running** for the Testcontainers test; it is not
available in the environment this was authored in, so verification here used three things instead:
unit tests (`./mvnw test -Dtest='!PostgresIntegrationTest'`, 52 tests, all passing), a clean
compile, and replaying every migration (V1–V8) against H2 in PostgreSQL-compatibility mode via a
throwaway JDBC script — a genuine syntax/consistency check (it caught a real typo during
authoring), but not equivalent to running them against real Postgres. GitHub Actions runs the full
`mvn -B verify` (Docker included, `working-directory: backend`) on every push and pull request.

| Test class | Tests | Covers |
| --- | --- | --- |
| `AuthServiceTest` | 10 | Registration, duplicate email, login, generic auth failure wording, refresh-token rotation, rejecting an expired/revoked/unknown refresh token, logout revoking the matching token, logout being a no-op for an unknown token |
| `ChildServiceTest` | 3 | Child creation, default grade/avatar/preferences when omitted, listing only owned profiles |
| `LessonCatalogServiceTest` | 5 | Sort order, lookup by code, not-found, exposing exercises without an answer index, subject lookup |
| `ExerciseEvaluationServiceTest` | 5 | Correct answer (no hint returned), incorrect answer (hint returned), skill-progress accumulation across attempts, unknown exercise, ownership check |
| `ProgressServiceTest` | 4 | Lesson marked complete once every exercise is attempted (coins awarded exactly once), not complete until then, no double-award on re-recalculation, ownership check |
| `RewardsServiceTest` | 7 | Coin award + streak advance on a new event, no double-award for an already-recorded reference, treating a concurrent duplicate insert as already-awarded rather than failing, streak increment, streak reset after a gap, reading the ledger-summed balance, ownership check |
| `BadgeServiceTest` | 5 | Awarding FIRST_STEPS on the first completed lesson, not re-awarding it, awarding FIVE_DAY_STREAK at 5 days, not awarding it below 5, ownership check on listing |
| `TutorServiceTest` | 5 | Offline strategy rotation across attempts, real AI client used when configured, fallback to offline when the real call fails, blank-question rejection, ownership check |
| `HomeworkServiceTest` | 5 | Offline guidance shape, parsing a real AI response into steps + hint, fallback to offline when the real call fails, blank-question rejection, ownership check |
| `DashboardServiceTest` | 3 | Aggregation across subjects, empty-progress child, ownership check |
| `PostgresIntegrationTest` | 1 | Flyway migrations apply cleanly against real PostgreSQL (requires Docker) |

**53 backend tests** (52 unit + 1 Docker-dependent integration test).

Not covered by an automated test: the Redis-backed `AuthRateLimitFilter` itself and a full Spring
context boot with Redis actually wired (both would need a real or embedded Redis instance; not
added without checking scope with the project owner first).

## Mobile

```sh
cd mobile
flutter pub get
flutter analyze   # 0 issues
flutter test      # 9 tests, all passing
```

| Test file | Covers |
| --- | --- |
| `lesson_test.dart` | `Lesson`/`Exercise` JSON parsing (no answer index) and `ExerciseEvaluation` parsing (hint present only when incorrect) — replaces `lesson_attempt_test.dart`, whose `LessonAttempt` client-side scoring logic no longer exists now that grading is server-side |
| `novalearn_api_test.dart` | API client request shapes for register/refresh/submit-answer, and error-to-exception mapping |
| `widget_test.dart` | The sign-in screen renders and the register/sign-in toggle works, with `AuthScreen` wrapped in a `ProviderScope` overriding `sessionControllerProvider` with fakes (a real `SessionController` backed by a fake `AuthRepository` and an inert `SessionStore` subclass, so the test never touches the unavailable-under-test `flutter_secure_storage` platform channel) |

## What is not tested or verified here

- The real Anthropic-backed path (`AnthropicTextClient`) — implemented, not exercised against the
  live API in this environment (no key provisioned). See RISKS_AND_TRADEOFFS.md.
- The PostgreSQL Testcontainers test — requires Docker, unavailable in this authoring environment;
  mitigated by the H2 migration-replay check described above, which is not equivalent.
- The mobile app has not been run on a simulator/emulator or a physical device in this
  environment (no device/emulator attached); verification here is `flutter analyze` + `flutter
  test` only, not a manual run-through of the UI — this matters more now than before, since the
  new per-exercise `LessonScreen` flow (submit one answer at a time, show feedback, advance) has
  never been visually exercised, only unit/widget-tested at the data layer.
- No end-to-end test exercises the full stack (mobile hitting a live backend hitting a live
  Postgres) — each half is verified independently.
- The Redis-backed rate limiter — see "Backend" above.
