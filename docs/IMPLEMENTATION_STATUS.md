# Implementation Status

Last updated: this session (master-spec alignment pass, Phase 0 + partial Phase 1).

## What exists coming into this session

A working backend (parent auth, child profiles, a 5-lesson/2-subject catalog, progress tracking,
coin/streak gamification, an AI tutor, a text-based homework helper, a parent dashboard) and a
Flutter mobile client wired to all of it, built in earlier sessions before this master spec was
provided. 33 backend unit tests, 7 mobile tests, both suites green.

## What this session did (Phase 0 + Phase 1 items)

### Phase 0 — Inspect and plan

- Inspected tooling: Java 23 runtime (pom targets `--release 21`), Maven wrapper 3.9.11, Flutter
  3.44.9, Git 2.50.1. **Not available**: Docker, `psql`, `redis-cli`, `gh` CLI.
- Restructured the repo into the monorepo layout the master spec asks for:
  `backend/` (was repo root), `mobile/` (already there), `docs/` (new — PRD/ARCHITECTURE/TESTING/
  RISKS_AND_TRADEOFFS moved in, four new docs added), `infrastructure/` (new). Root `CLAUDE.md`
  added. `docker-compose.yml` moved to repo root and updated (build context `./backend`, Redis
  service added). `.github/workflows/ci.yml` updated for the new `backend/` path. All moves used
  `git mv` to preserve history.
- Wrote: `docs/ARCHITECTURE.md` (rewritten), `docs/DATABASE_DESIGN.md` (new),
  `docs/API_SPECIFICATION.md` (new), `docs/SECURITY_AND_CHILD_SAFETY.md` (new),
  `docs/DEVELOPMENT_PLAN.md` (new, maps this session's phases onto the master spec's phases),
  `docs/ADR/0001`–`0004` (new), this file.

### Phase 1 — Working backend foundation

- **Refresh tokens** (did not exist before): `domain.auth.RefreshToken`,
  `application.auth.RefreshTokenRepository` (port), `infrastructure.persistence.RefreshTokenEntity`
  + JPA adapter, migration `V3__create_refresh_tokens.sql`. `AuthService` now issues a rotating,
  single-use refresh token on register/login, validates+rotates it on `POST /auth/refresh`, and
  revokes it on `POST /auth/logout`. Raw tokens are never persisted, only a SHA-256 hash.
- **Redis-backed rate limiting** on `POST /api/v1/auth/**`: `infrastructure.security.
  AuthRateLimitFilter`, wired into `SecurityConfig`. Fails open (allows the request, logs a
  warning) if Redis is unreachable. `spring-boot-starter-data-redis` added to `pom.xml`;
  `docker-compose.yml` runs a Redis container; `application.yml` reads `REDIS_HOST`/`REDIS_PORT`.
- **`ChildProfile` extended** with `gradeLevel`, `avatar`, `learningPreferences` — all optional
  with defaults (`GRADE_1`/`FOX`/empty set) so the existing mobile "add child" flow, which only
  sends `displayName`/`birthDate`, keeps working unmodified. New domain enums
  `GradeLevel`/`Avatar`/`LearningPreference`; migration `V4__add_child_profile_attributes.sql`
  (two new columns + a `child_learning_preferences` join table); `ChildProfileEntity` updated with
  an `@ElementCollection`.
- Updated `AuthServiceTest` (10 tests, up from 4) and `ChildServiceTest` (3 tests, up from 2) to
  cover all of the above; both green.

## Commands actually executed, and their results

```sh
cd backend && ./mvnw -q clean test -Dtest='!PostgresIntegrationTest' -DfailIfNoTests=false
# -> 40 tests, 0 failures, 0 errors (run repeatedly through this session, after each change)

cd backend && ./mvnw clean verify
# -> 41 tests run, 40 pass, 1 error: PostgresIntegrationTest fails with
#    "IllegalState: Could not find a valid Docker environment." (expected — no Docker here)

cd mobile && flutter analyze
# -> "No issues found!"

cd mobile && flutter test --reporter expanded
# -> "All tests passed!" (7 tests)
```

No command was run and then assumed to pass without observing its output — every number above is
copied from an actual run in this session, not estimated.

## Known issues / explicitly deferred (see docs/DEVELOPMENT_PLAN.md and docs/RISKS_AND_TRADEOFFS.md for the full list)

- Mobile does not yet use the new refresh token (still only persists the access token) — not a
  regression, just not caught up yet (Phase 3).
- No automated test exercises `AuthRateLimitFilter` against a real/embedded Redis.
- The richer curriculum/exercise/skill/reward-ledger/badge schema from the master spec is not
  built — explicitly deferred to Phase 2, with a schema sketch already written in
  `docs/DATABASE_DESIGN.md` so that phase starts from a reviewed plan.
- Riverpod migration (ADR 0003) decided, not implemented (Phase 3).
- AI output structured-validation/strict-schema/refusal-handling not implemented — see
  `docs/SECURITY_AND_CHILD_SAFETY.md` for why (never exercised against a real model response in
  this environment) and `docs/DEVELOPMENT_PLAN.md` Phase 4 for the plan.

## Exact next action

Start Phase 2 ("Learning engine"): build the `Exercise`/`ExerciseAttempt`/`Skill`/`SkillProgress`
entities and endpoints, replace the single-row `child_rewards` accumulator with an auditable
`reward_transactions` ledger, and add badges — using the schema already sketched in
`docs/DATABASE_DESIGN.md` as the starting point. Verify with real `./mvnw test` runs after each
sub-step, the same way this session did, rather than attempting the whole phase in one pass.
