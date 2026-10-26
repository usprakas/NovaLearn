# Testing

## Backend

Commands run from `backend/`. `./mvnw clean verify` runs the full unit suite plus a PostgreSQL
Testcontainers integration test. **Docker must be running** for the Testcontainers test; it is not
available in the environment this was authored in, so verification here used three things instead:
unit tests (`./mvnw test -Dtest='!PostgresIntegrationTest'`, 64 tests, all passing), a clean
compile, and replaying every migration (V1–V8) against H2 in PostgreSQL-compatibility mode via a
throwaway JDBC script — a genuine syntax/consistency check (it caught a real typo during
authoring), but not equivalent to running them against real Postgres. GitHub Actions runs the full
`mvn -B verify` (Docker included, `working-directory: backend`) on every push and pull request.

| Test class | Tests | Covers |
| --- | --- | --- |
| `AuthServiceTest` | 12 | Registration, duplicate email, login, generic auth failure wording, refresh-token rotation, rejecting an expired/revoked/unknown refresh token, logout revoking the matching token, logout being a no-op for an unknown token, account deletion after password re-confirmation, refusing deletion on a wrong password |
| `ChildServiceTest` | 3 | Child creation, default grade/avatar/preferences when omitted, listing only owned profiles |
| `LessonCatalogServiceTest` | 5 | Sort order, lookup by code, not-found, exposing exercises without an answer index, subject lookup |
| `ExerciseEvaluationServiceTest` | 5 | Correct answer (no hint returned), incorrect answer (hint returned), skill-progress accumulation across attempts, unknown exercise, ownership check |
| `ProgressServiceTest` | 4 | Lesson marked complete once every exercise is attempted (coins awarded exactly once), not complete until then, no double-award on re-recalculation, ownership check |
| `RewardsServiceTest` | 7 | Coin award + streak advance on a new event, no double-award for an already-recorded reference, treating a concurrent duplicate insert as already-awarded rather than failing, streak increment, streak reset after a gap, reading the ledger-summed balance, ownership check |
| `BadgeServiceTest` | 5 | Awarding FIRST_STEPS on the first completed lesson, not re-awarding it, awarding FIVE_DAY_STREAK at 5 days, not awarding it below 5, ownership check on listing |
| `TutorServiceTest` | 9 | Offline rotation across all 5 strategies, real AI client used when configured, fallback to offline when the real call fails, blank-question rejection, ownership check, refusing an unsafe question without ever calling the AI client, treating an unsafe real AI response as untrusted and falling back offline, suggesting a lesson in the requested subject |
| `HomeworkServiceTest` | 7 | Offline guidance shape, parsing a real AI response into steps + hint, fallback to offline when the real call fails, blank-question rejection, ownership check, refusing an unsafe question without ever calling the AI client, treating an unsafe real AI response as untrusted and falling back offline |
| `DashboardServiceTest` | 4 | Aggregation across subjects, empty-progress child, ownership check, recommending the first incomplete catalog lesson |
| `CorrelationIdFilterTest` | 3 | Generating and echoing an ID when the client sends none, reusing a client-supplied ID, clearing the MDC entry even when the chain throws |
| `PostgresIntegrationTest` | 1 | Flyway migrations apply cleanly against real PostgreSQL (requires Docker) |

**65 backend tests** (64 unit + 1 Docker-dependent integration test).

Not covered by an automated test: the Redis-backed `AuthRateLimitFilter`/`AiRateLimitFilter`
themselves and a full Spring context boot with Redis actually wired (both would need a real or
embedded Redis instance; not added without checking scope with the project owner first).

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
- The Redis-backed rate limiters (`AuthRateLimitFilter`, `AiRateLimitFilter`) — see "Backend"
  above.
- The content safety filter's denylist check against a *real* AI response is unit-tested with a
  mocked `AiTextClient` returning deliberately-unsafe text, not against actual Anthropic output —
  no API key is provisioned in this environment (see RISKS_AND_TRADEOFFS.md).
- Mobile has no test for the new dashboard "recommended next" card or the tutor screen's
  refusal/suggestion UI beyond what the existing `flutter analyze`/widget tests already cover
  indirectly through the unchanged `AuthScreen` flow — these were verified by `flutter analyze`
  (0 issues) and the full `flutter test` suite (9 tests, unchanged in count), not by a dedicated
  widget test for the new UI states, and not on a real device/emulator.
- Phase 6 items (OCR, speech-to-text/TTS, AWS deployment, teacher dashboard, billing) are a plan
  only — see `docs/PHASE_6_PLAN.md` — nothing there has been built or tested.
