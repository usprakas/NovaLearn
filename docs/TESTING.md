# Testing

## Backend

Commands run from `backend/`. `./mvnw clean verify` runs the full unit suite plus a PostgreSQL
Testcontainers integration test. **Docker must be running** for the Testcontainers test; it is not
available in the environment this was authored in, so it was verified by running everything else
(`./mvnw test -Dtest='!PostgresIntegrationTest'`, 40 tests, all passing) plus a clean compile and
a manual review of the new migrations (`V3__create_refresh_tokens.sql`,
`V4__add_child_profile_attributes.sql`) against `V1`/`V2`'s conventions. GitHub Actions runs the
full `mvn -B verify` (Docker included, `working-directory: backend`) on every push and pull
request.

| Test class | Tests | Covers |
| --- | --- | --- |
| `AuthServiceTest` | 10 | Registration, duplicate email, login, generic auth failure wording, refresh-token rotation, rejecting an expired/revoked/unknown refresh token, logout revoking the matching token, logout being a no-op for an unknown token |
| `ChildServiceTest` | 3 | Child creation, default grade/avatar/preferences when omitted, listing only owned profiles |
| `ProgressServiceTest` | 4 | Score/completion merge, ownership check, reward triggered exactly once on first completion |
| `LessonCatalogTest` | 4 | Sort order, lookup by code, subject lookup, not-found |
| `RewardsServiceTest` | 6 | Coin award, perfect-score bonus, streak increment, streak reset after a gap, no double-count same day, ownership check |
| `TutorServiceTest` | 5 | Offline strategy rotation across attempts, real AI client used when configured, fallback to offline when the real call fails, blank-question rejection, ownership check |
| `HomeworkServiceTest` | 5 | Offline guidance shape, parsing a real AI response into steps + hint, fallback to offline when the real call fails, blank-question rejection, ownership check |
| `DashboardServiceTest` | 3 | Aggregation across subjects, empty-progress child, ownership check |
| `PostgresIntegrationTest` | 1 | Flyway migrations apply cleanly against real PostgreSQL (requires Docker) |

**41 backend tests** (40 unit + 1 Docker-dependent integration test).

Not covered by an automated test: the Redis-backed `AuthRateLimitFilter` itself (would need a real
or embedded Redis instance in the test; not added without checking scope with the project owner
first) and the full Spring context boot with Redis actually wired (same reason — no Redis
available to test against in this environment).

## Mobile

```sh
cd mobile
flutter pub get
flutter analyze   # 0 issues
flutter test      # 7 tests, all passing
```

| Test file | Covers |
| --- | --- |
| `lesson_attempt_test.dart` | `LessonAttempt` completion/scoring logic against the offline fixture lesson |
| `novalearn_api_test.dart` | API client request shape and error-to-exception mapping |
| `widget_test.dart` | The sign-in screen renders and the register/sign-in toggle works (replaces the stock Flutter counter-app template test, which referenced a `MyApp` class that was never part of this app) |

## What is not tested or verified here

- The real Anthropic-backed path (`AnthropicTextClient`) — implemented, not exercised against the
  live API in this environment (no key provisioned). See RISKS_AND_TRADEOFFS.md.
- The PostgreSQL Testcontainers test — requires Docker, unavailable in this authoring environment.
- The mobile app has not been run on a simulator/emulator or a physical device in this
  environment (no device/emulator attached); verification here is `flutter analyze` + `flutter
  test` only, not a manual run-through of the UI.
- No end-to-end test exercises the full stack (mobile hitting a live backend hitting a live
  Postgres) — each half is verified independently.
