# Development Plan

Phases as defined in the master spec. Status is kept current here; `docs/IMPLEMENTATION_STATUS.md`
has the detailed log (files touched, commands run, test results) for the current/most recent work
session.

## Phase 0 — Inspect and plan — ✅ done (this pass)

Tooling inspected (Java 23 runtime / pom targets 21, Maven wrapper 3.9.11, Flutter 3.44.9, Git
2.50.1; no Docker, no `psql`, no `redis-cli`, no `gh` CLI available in this environment). Repo
restructured into `backend/` + `mobile/` + `docs/` + `infrastructure/`. This document and its
siblings in `docs/` written.

## Phase 1 — Working backend foundation — 🟡 mostly done

| Item | Status |
| --- | --- |
| Spring Boot project, PostgreSQL, Flyway | ✅ pre-existing, carried forward |
| Docker Compose (Postgres + **Redis**, API) | ✅ this pass — `docker-compose.yml` moved to repo root, Redis service added |
| Health checks | ✅ pre-existing (`/actuator/health`) |
| Authentication + authorization | ✅ this pass — added rotating refresh tokens (`/auth/refresh`, `/auth/logout`), Redis-backed rate limiting on auth endpoints |
| Parent and child profiles | 🟡 this pass — added `gradeLevel`/`avatar`/`learningPreferences` (optional, backward-compatible defaults); still uses `birthDate` rather than a coarser age range (see RISKS_AND_TRADEOFFS.md) |
| Sample curriculum and lesson APIs | ✅ pre-existing — 5 lessons, 2 subjects, served from `LessonCatalog` (in-code, not DB — see DATABASE_DESIGN.md) |
| Tests | ✅ 40 unit tests passing (`./mvnw test -Dtest='!PostgresIntegrationTest'`); Postgres Testcontainers test unverified locally (no Docker here), runs in CI |

**Not done in Phase 1**: Redis is wired for rate limiting only, not caching (the spec lists caching
as optional). No automated test exercises the Redis rate limiter itself (would need either a real
Redis or an embedded one — not added to avoid a new test-scope dependency decision without
checking with the project owner first).

## Phase 2 — Learning engine — ⬜ not started

Exercise evaluation as its own resource, attempt recording, skill-level progress tracking, a
`reward_transactions` ledger (replacing today's single-row accumulator), and badges. Schema sketch
already written in `docs/DATABASE_DESIGN.md` so this phase starts from a reviewed plan rather than
a blank page. Explicitly deferred rather than rushed into this pass — this is the single largest
remaining piece of backend work and deserves its own focused, verified increment.

## Phase 3 — Flutter application — ⬜ not started (existing app predates this spec)

The mobile app already implements: parent sign-in, child profiles, a dynamic lesson list, lesson
play with feedback, a tutor screen, a homework screen, and a parent dashboard — built in an earlier
pass, using plain `StatefulWidget`/`FutureBuilder`, not Riverpod. This spec calls for Riverpod
specifically (`docs/ADR/0003-state-management.md`). Migrating the existing screens is a real
rewrite, not a tweak, and has not been started. The mobile app also does not yet send/store the new
refresh token the backend now issues (it still only persists the access token) — that is a Phase 3
catch-up item, not a backend regression (the old 2-field login response shape still round-trips
through the richer response; the mobile client simply ignores the extra fields today).

## Phase 4 — AI tutor — 🟡 partially done (built in an earlier pass, predates this spec's full requirements)

| Requirement | Status |
| --- | --- |
| Provider-independent interface | ✅ `AiTextClient` |
| Deterministic fallback | ✅ |
| Optional real LLM adapter | ✅ Anthropic, gated by `ANTHROPIC_API_KEY`; **never exercised against the live API in this environment** |
| Structured output validation / strict schema | ⬜ not implemented — see SECURITY_AND_CHILD_SAFETY.md |
| Full strategy set (`VISUAL_ANALOGY`, `GUIDED_QUESTION`) | ⬜ only `STEP_BY_STEP`/`STORY`/`REAL_LIFE_EXAMPLE` exist today |
| Refusal handling for inappropriate/unrelated requests | ⬜ not implemented |
| Per-child/session rate limiting on AI calls | ⬜ not implemented — do not enable a real API key in a shared environment until this exists (see SECURITY_AND_CHILD_SAFETY.md) |

## Phase 5 — Parent dashboard and hardening — 🟡 partially done

Weekly summary + strongest/weakest subject exist (`DashboardService`). Security/authorization
tests exist per-service (ownership checks). Not done: a dedicated recommended-next-activity field,
broader error-handling/logging/accessibility/performance pass, and an account-deletion endpoint
(retention mechanics at the schema level exist via `ON DELETE CASCADE`; no API triggers it yet).

## Phase 6 — Future extensions — ⬜ not started, and not begun per the master spec's own instruction

Homework OCR, speech-to-text/text-to-speech, additional subjects/grades beyond what Phase 2
delivers, a teacher dashboard, subscription billing, and AWS infrastructure-as-code. See
`infrastructure/README.md`. Do not start this phase until explicitly asked.

## Recorded assumptions (per "use defaults, record assumptions" instruction)

- Treated the already-substantial existing backend/mobile implementation (parent auth, child
  profiles, lesson catalog, progress, rewards, tutor, homework, dashboard) as "useful work to
  preserve and extend," per the instruction to inspect before editing — not rebuilt from zero.
- Interpreted "sample curriculum and lesson APIs" (Phase 1) as satisfied by the existing in-code
  `LessonCatalog` + its REST endpoints, and treated the master spec's much richer
  `Exercise`/`Skill`/`ExerciseAttempt`/ledger/badge entity model as Phase 2 scope instead, per the
  master spec's own Phase 2 checklist ("implement exercise evaluation... progress and skill
  tracking... rewards ledger and badges").
- `gradeLevel`/`avatar`/`learningPreferences` were added to `ChildProfile` as **optional** fields
  with defaults, specifically so the existing (pre-this-pass) mobile "add child" flow keeps working
  without modification. A stricter reading of the spec might make these required at creation time;
  revisit once mobile Phase 3 actually collects them from a UI.
- Refresh-token TTL defaulted to 30 days, access-token TTL left at the pre-existing 1 hour default,
  and the auth rate limit defaulted to 10 requests/minute/IP — all configurable via environment
  variables, none are a considered product decision, just a reasonable starting point.
