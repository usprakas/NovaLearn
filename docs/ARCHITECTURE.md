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
  +-- Curriculum and Lessons             (application/catalog — in-code catalog, see below)
  +-- Learning Progress                  (application/progress)
  +-- Rewards                            (application/rewards)
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
| `domain` | Stable concepts with no framework dependency: `Role`, `ChildProfile` (+ `GradeLevel`, `Avatar`, `LearningPreference`), `LessonProgress`, `LessonDefinition`, `ChildRewards`, `TutorAnswer`, `HomeworkGuidance`, `ChildDashboard`, `RefreshToken`. |
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
  requests/minute, configurable). If Redis is unreachable, the limiter fails open and logs a
  warning rather than breaking authentication entirely — Redis is an optional dependency for this
  MVP, not a hard requirement.

## Curriculum and lessons

The lesson catalog (5 lessons across Math and English) is served from in-code data
(`application.catalog.LessonCatalog`), not a database table. This carries forward a deliberate
Sprint 1 decision: lesson codes are opaque strings with no foreign key into a catalog table, so
curriculum can expand without a schema migration. `docs/DATABASE_DESIGN.md` documents why the
richer entity model this spec describes (`Subject`, `CurriculumUnit`, `Skill`, `Exercise`,
`ExerciseAttempt`, `LearningSession`, `SkillProgress`, `RewardTransaction` ledger, `Badge`,
`ChildBadge`, `TutorSession`, `TutorMessage`) is **not yet built** — it is explicitly scoped as the
next phase ("Phase 2 — Learning engine"), not retrofitted hastily into this pass. Lesson scoring is
still computed client-side and submitted as a final score; nothing re-grades it server-side yet.

## AI tutor and homework helper

Both share one port, `application.ai.AiTextClient`. `config.AiConfig` registers a real
`AnthropicTextClient` bean only when `ANTHROPIC_API_KEY` is set; otherwise no bean is registered,
which Spring exposes to constructor-injected `Optional<AiTextClient>` consumers as
`Optional.empty()`. `TutorService`/`HomeworkService` catch a failure from the real client and fall
back to the deterministic offline template for that one request, so a transient provider outage
degrades gracefully instead of 500ing. See `docs/SECURITY_AND_CHILD_SAFETY.md` for the child-safety
posture around model output.

## What this does not include yet

Stated plainly rather than discovered later — see `docs/RISKS_AND_TRADEOFFS.md` and
`docs/DEVELOPMENT_PLAN.md` for the full list and the phase each belongs to: the richer curriculum/
exercise/skill/reward-ledger/badge/tutor-session schema (Phase 2), Riverpod state management on
mobile (Phase 3; the app currently uses plain `StatefulWidget`/`FutureBuilder`), homework OCR and
voice I/O (explicitly later-phase per the PRD), a teacher dashboard, AWS infrastructure-as-code,
and Cognito integration (Phase 6, not started — see `infrastructure/README.md`).
