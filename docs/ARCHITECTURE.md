# NovaLearn Architecture

## Style: modular monolith

One Spring Boot application, organized by ports-and-adapters layering, not microservices. See
`docs/ADR/0001-modular-monolith.md` for the reasoning.

```
Flutter Mobile App
        |
        | HTTPS / JSON
        v
Spring Boot REST API (backend/)
  +-- Authentication and Authorization   (application/auth, infrastructure/security)
  +-- Parent and Child Profiles          (application/child)
  +-- Curriculum and Lessons             (application/catalog — DB-backed, see below)
  +-- Learning Progress + Exercises      (application/progress)
  +-- Rewards, Streaks, Badges           (application/rewards)
  +-- AI Tutor / Homework Helper         (application/tutor, application/homework, application/ai)
  +-- Parent Analytics                   (application/dashboard)
        |
        +-- PostgreSQL (Flyway-migrated)
        +-- Redis (optional — rate limiting today; caching is not yet implemented)
        +-- AiTextClient adapter (optional — offline by default, real Anthropic API if configured)
```

## Boundaries

| Layer | Responsibility |
| --- | --- |
| `domain` | Stable concepts with no framework dependency: `Role`, `ChildProfile` (+ `GradeLevel`, `Avatar`, `LearningPreference`), `LessonDefinition`, `Exercise` (no answer index — see below), `LessonProgress`, `ExerciseAttempt`, `SkillProgress`, `ExerciseEvaluation`, `ChildStreak`, `RewardTransaction`, `Badge`, `ChildBadge`, `ChildRewardsSummary`, `TutorAnswer`, `HomeworkGuidance`, `ChildDashboard`, `RefreshToken`. |
| `application` | Use cases and ports. No Spring Data or HTTP dependency (the `ai` package's `AiTextClient` port is implemented by `infrastructure`). |
| `infrastructure` | JPA persistence, JWT issuance/parsing, the Redis-backed rate limiter, and the real Anthropic HTTP client. |
| `interfaces/rest` | Controllers, request/response DTOs, and error translation. Never exposes JPA entities. |
| `config` | Security filter chain, OpenAPI, `Clock`, and `AiTextClient` wiring. |

Every child-scoped operation is parent-scoped: the application service checks
`ChildProfileRepository.belongsToParent` (or the equivalent for a given aggregate) before any read
or write, and throws the shared `application.common.ChildNotFoundException` (mapped to 404)
otherwise. `ProgressService`, `RewardsService`, `TutorService`, `HomeworkService`, and
`DashboardService` all follow this pattern.

## Authentication

Short-lived HMAC-signed JWT access tokens (`novalearn.security.access-token-ttl-seconds`, default
3600s) plus a long-lived, rotating, single-use refresh token:

- A refresh token is a 256-bit random value, base64url-encoded, returned to the client exactly
  once. Only its SHA-256 hash is ever persisted (`refresh_tokens.token_hash`).
- `POST /api/v1/auth/refresh` revokes the presented token and issues a brand-new access/refresh
  pair (rotation). Presenting an already-revoked, expired, or unknown token is rejected with the
  same generic authentication error used for a bad password, so a caller cannot distinguish "token
  revoked" from "token never existed."
- `POST /api/v1/auth/logout` revokes the presented refresh token. The paired access token is not
  separately invalidated — it simply expires on its own short TTL. A stateful access-token
  blocklist was judged out of scope for the MVP; see `docs/RISKS_AND_TRADEOFFS.md`.
- Login/register/refresh/logout are rate-limited per client IP via Redis (fixed window, default 10
  requests/minute, configurable). If Redis is unreachable, the limiter falls back to an in-process
  counter (exact for a single instance) and logs a warning, rather than breaking authentication or
  silently disabling the limit — Redis is an optional dependency for this
  MVP, not a hard requirement.

## Curriculum, exercises, and server-side grading

The lesson catalog (five Grade 1 Math lessons — see "Curriculum scope" in
`docs/DATABASE_DESIGN.md` for why English content from an earlier session isn't here) is now
DB-backed (`lessons`, `exercises`, `exercise_choices`), served through
`application.catalog.LessonCatalogService`. This supersedes the original Sprint 1 "keep it in
code" decision, not because five lessons needed enterprise normalization, but because exercises
needed individually addressable, server-side-only identities once grading moved server-side (see
below) — `docs/ADR/0001`-adjacent reasoning, written up fully in `docs/DATABASE_DESIGN.md`.

**Exercise answers are graded server-side, not by the client.** `GET /lessons/{code}` returns each
exercise's prompt and choices but never its answer index — the index lives only behind
`application.catalog.ExerciseAnswerKey`, fetched exclusively by
`application.progress.ExerciseEvaluationService` and never passed to a controller. Submitting an
answer (`POST .../exercises/{exerciseId}/attempts`) records the attempt, updates
`SkillProgress` (a plain accuracy ratio — see "Mastery algorithm" in DATABASE_DESIGN.md), and
triggers `ProgressService.recalculate`, which derives the owning lesson's completion/score from
every exercise attempted so far. There is no longer a way for a client to set its own score or
completion flag — the `PUT .../progress/{lessonCode}` endpoint that used to allow exactly that is
gone (see `docs/RISKS_AND_TRADEOFFS.md` for why that was a real gap, not just a style choice).

**Rewards are an auditable ledger, not a mutable counter.** `RewardsService.award` is idempotent
on `(referenceType, referenceId)` — checked in application code and enforced by a database unique
constraint, so a retried request can never double-award. `coins` is `SUM(delta_coins)` over
`reward_transactions`, computed on read, not stored. Streak state (`current_streak`,
`longest_streak`, `last_activity_date`) stays a separate mutable row (`child_streaks`), since a
streak genuinely is state, not a transaction amount. `BadgeService` evaluates two fixed, simple
criteria (first lesson completed; five-day streak) after every award — deliberately not a generic
rules engine.

## AI tutor and homework helper

Both share one port, `application.ai.AiTextClient`. `config.AiConfig` registers a real
`AnthropicTextClient` bean only when `ANTHROPIC_API_KEY` is set; otherwise no bean is registered,
which Spring exposes to constructor-injected `Optional<AiTextClient>` consumers as
`Optional.empty()`. `TutorService`/`HomeworkService` catch a failure from the real client and fall
back to the deterministic offline template for that one request, so a transient provider outage
degrades gracefully instead of 500ing. See `docs/SECURITY_AND_CHILD_SAFETY.md` for the child-safety
posture around model output.

## Mobile: Riverpod at the app-wiring layer

Per `docs/ADR/0003-state-management.md`, the mobile app now uses Riverpod — but scoped
deliberately, not as a wholesale rewrite of every widget. `SessionController`
(`features/auth/application/session_controller.dart`), a `StateNotifier<AsyncValue<Session?>>`,
owns session restore/login/register/sign-out, replacing the hand-rolled `_SessionGateState` that
used to manually thread `Session`/`NovaLearnApi` through `app.dart` → `HomeScreen` → every tab.
`app.dart` and `AuthScreen` are now `ConsumerWidget`/`ConsumerStatefulWidget`, reading
`sessionControllerProvider` instead of receiving callbacks via constructor. Below that layer,
`HomeScreen` still passes the resolved `token`/`api` down to its tabs via constructor parameters —
a deliberate choice, not an oversight: those leaf widgets (`LessonListTab`, `TutorTab`,
`HomeworkTab`, `ParentDashboard`) each already own a clean, narrow dependency list, and converting
every one of them to read providers directly would be churn without a corresponding problem it
solves. Riverpod lives exactly where the original pain was.

## What this does not include yet

Stated plainly rather than discovered later — see `docs/RISKS_AND_TRADEOFFS.md` and
`docs/DEVELOPMENT_PLAN.md` for the full list and the phase each belongs to: automatic silent
token refresh on a 401 (the refresh token is stored and `AuthRepository.refresh`/`logout` exist,
but nothing retries a failed request after refreshing yet), homework OCR and voice I/O (explicitly
later-phase per the PRD), a teacher dashboard, AWS infrastructure-as-code, and Cognito integration
(Phase 6, not started — see `infrastructure/README.md`).
