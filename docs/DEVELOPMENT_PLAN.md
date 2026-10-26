# Development Plan

Phases as defined in the master spec. Status is kept current here; `docs/IMPLEMENTATION_STATUS.md`
has the detailed log (files touched, commands run, test results) for the current/most recent work
session.

## Phase 0 — Inspect and plan — ✅ done

Tooling inspected (Java 23 runtime / pom targets 21, Maven wrapper 3.9.11, Flutter 3.44.9, Git
2.50.1; no Docker, no `psql`, no `redis-cli`, no `gh` CLI available in this environment). Repo
restructured into `backend/` + `mobile/` + `docs/` + `infrastructure/`.

## Phase 1 — Working backend foundation — ✅ done

| Item | Status |
| --- | --- |
| Spring Boot project, PostgreSQL, Flyway | ✅ |
| Docker Compose (Postgres + Redis, API) | ✅ |
| Health checks | ✅ (`/actuator/health`) |
| Authentication + authorization | ✅ rotating refresh tokens (`/auth/refresh`, `/auth/logout`), Redis-backed rate limiting on auth endpoints |
| Parent and child profiles | 🟡 `gradeLevel`/`avatar`/`learningPreferences` added (optional, backward-compatible defaults); still uses `birthDate` rather than a coarser age range (see RISKS_AND_TRADEOFFS.md) |
| Sample curriculum and lesson APIs | ✅ now DB-backed (superseded by Phase 2 — see below) |
| Tests | ✅ |

**Not done**: Redis is wired for rate limiting only, not caching (the spec lists caching as
optional). No automated test exercises the Redis rate limiter itself (would need either a real
Redis or an embedded one).

## Phase 2 — Learning engine — ✅ done

| Item | Status |
| --- | --- |
| Exercise evaluation as its own resource | ✅ `POST /children/{id}/exercises/{id}/attempts`; answer index never leaves the server (`ExerciseAnswerKey`) |
| Attempt recording | ✅ `exercise_attempts` table, one row per submission |
| Skill-level progress tracking | ✅ `skill_progress` — plain accuracy ratio, deliberately not a sophisticated mastery model |
| Rewards ledger | ✅ `reward_transactions`, idempotent on `(reference_type, reference_id)` via app check + DB unique constraint |
| Badges | ✅ two fixed badges (`FIRST_STEPS`, `FIVE_DAY_STREAK`), evaluated automatically after every award |
| Integration tests for the complete learning flow | 🟡 thorough unit tests across every new service (`ExerciseEvaluationServiceTest`, `ProgressServiceTest`, `RewardsServiceTest`, `BadgeServiceTest`), but no single Testcontainers-backed end-to-end test exercising the real database — would need Docker, unavailable here |

Curriculum content was narrowed to exactly the five Math topics the master spec names (Counting,
Addition, Subtraction, Comparison, Word Problems) rather than carrying forward the pre-spec
session's English lessons — see "Curriculum scope" in DATABASE_DESIGN.md.

**The client-submittable progress endpoint was removed, not just supplemented.**
`PUT /children/{id}/progress/{lessonCode}` let a client set its own score/completion with zero
server-side verification; it is gone, replaced entirely by exercise-attempt submission + derived
recalculation. This was judged correct rather than additive-only, because leaving the old endpoint
in place alongside the new one would mean the integrity gap it existed to close was still open.

## Phase 3 — Flutter application — ✅ done (scoped)

| Item | Status |
| --- | --- |
| Riverpod state management | ✅ at the app-wiring layer (session/auth) — see ADR 0003 for exactly what did and didn't change |
| Onboarding and authentication | ✅ pre-existing, now Riverpod-backed |
| Child profiles and child dashboard | ✅ pre-existing, unchanged |
| Lessons, exercises, feedback, rewards, progress | ✅ `LessonScreen` rewritten for the new per-exercise server-graded flow (one exercise at a time, immediate correct/incorrect + explanation + optional hint, "next question"/"finish lesson") |
| Connect the screens to the backend | ✅ all repositories updated for the Phase 2 API shape changes (no `answerIndex` in lesson responses, no `PUT` progress, new exercise-attempt and badges endpoints) |
| Test the complete mobile flow | 🟡 `flutter analyze` (0 issues) + `flutter test` (9 tests) pass; the app has **not** been run on a simulator/emulator or device in this environment, so the new per-exercise `LessonScreen` UI has never been visually exercised — see TESTING.md |

**Not done**: automatic silent token refresh on a 401 (the refresh token is stored and the
`refresh`/`logout` API methods exist, but nothing retries a failed request after refreshing).
Badges are shown as plain chips on the parent dashboard rather than a dedicated screen — a
deliberate minimal-footprint choice, not every new backend capability needed its own screen.

## Phase 4 — AI tutor — ✅ done (within this environment's constraints)

| Requirement | Status |
| --- | --- |
| Provider-independent interface | ✅ `AiTextClient` |
| Deterministic fallback | ✅ |
| Optional real LLM adapter | ✅ Anthropic, gated by `ANTHROPIC_API_KEY`; **never exercised against the live API in this environment** |
| Structured output validation / strict schema | 🟡 upgraded from nothing to a keyword content-safety filter + length cap on both input and output (`ContentSafetyFilter`), but still no JSON-schema-constrained response format — see SECURITY_AND_CHILD_SAFETY.md |
| Full strategy set (`VISUAL_ANALOGY`, `GUIDED_QUESTION`) | ✅ all 5 strategies implemented, rotated via `attempt % 5` |
| Refusal handling for inappropriate/unrelated requests | ✅ an unsafe question is refused (`refused: true`) before the AI client is ever called; an unsafe real AI response falls back to the offline template |
| Per-child/session rate limiting on AI calls | ✅ `AiRateLimitFilter`, Redis-backed, 20/minute/child default, fails open — see SECURITY_AND_CHILD_SAFETY.md |
| Stateful tutor-session resource matching the spec's example route | ⬜ not implemented — endpoint remains stateless per-question; judged not worth building without a real conversation-memory design, see RISKS_AND_TRADEOFFS.md |

## Phase 5 — Parent dashboard and hardening — ✅ done (within this environment's constraints)

| Requirement | Status |
| --- | --- |
| Weekly summary, strongest/weakest subject, coins/streak/badges | ✅ pre-existing, unchanged |
| Recommended-next-activity field | ✅ `recommendedNextLessonCode`/`Title` — first incomplete catalog lesson, in display order |
| Account deletion | ✅ `DELETE /api/v1/auth/me`, password-reconfirmed, cascades to all child data at the DB level; **backend only — no mobile UI calls it yet** |
| Correlation-ID request logging | ✅ `CorrelationIdFilter`, echoed in `X-Correlation-Id` |
| Broader error-handling/logging pass | 🟡 the correlation-ID filter is the logging addition this pass made; no broader audit of every error path was done beyond what already existed |
| Accessibility pass | 🟡 documented rather than newly built — see "Mobile accessibility" in RISKS_AND_TRADEOFFS.md for exactly what is and isn't true today, and why a real pass needs a device this environment doesn't have |
| Performance pass | ⬜ not done — no load testing or query-plan review was performed; out of scope without real traffic patterns to test against |

## Phase 6 — Future extensions — ⬜ not started; a plan was written per the master spec's own instruction

Homework OCR, speech-to-text/text-to-speech, additional subjects/grades, a teacher dashboard,
subscription billing, and AWS infrastructure-as-code. A separate implementation plan (not code) was
written at `docs/PHASE_6_PLAN.md`, as the master spec itself asks for Phase 6 specifically — a
plan, not an implementation — and because every item needs a real external credential, cloud
account, or device this environment doesn't have. See also `infrastructure/README.md`. Do not
start building any of it until explicitly asked.

## Recorded assumptions (per "use defaults, record assumptions" instruction)

- Treated the already-substantial existing backend/mobile implementation as "useful work to
  preserve and extend," per the instruction to inspect before editing — not rebuilt from zero.
- Interpreted the master spec's richer `Exercise`/`Skill`/`ExerciseAttempt`/ledger/badge entity
  model as Phase 2 scope (per the spec's own Phase 2 checklist) and built it in full, including
  retiring the client-submittable progress endpoint it was meant to replace, rather than leaving
  both the old and new paths live side by side.
- Narrowed the DB-backed curriculum seed to exactly the five Math topics the spec names for the
  MVP, rather than carrying forward pre-spec English content — see DATABASE_DESIGN.md.
- `gradeLevel`/`avatar`/`learningPreferences` stayed **optional** fields with defaults (from the
  Phase 1 pass), and nothing in Phase 3's mobile work was changed to start collecting them from a
  UI — that remains open.
- Riverpod was scoped to the session/auth layer, not every widget — see ADR 0003's "Consequences"
  for the explicit boundary and the reasoning for not going further.
- Did not attempt automatic token-refresh-on-401; judged an unverified concurrency-sensitive
  interceptor worse than not building it, given no device/emulator to test it against.
- Refresh-token TTL defaulted to 30 days, access-token TTL left at the pre-existing 1 hour default,
  and the auth rate limit defaulted to 10 requests/minute/IP — all configurable via environment
  variables, none are a considered product decision, just a reasonable starting point.
- The Phase 4 content safety filter is a keyword denylist, chosen over a more elaborate check
  because there is no real AI key here to validate anything fancier against real model output —
  see "Known limitations" in RISKS_AND_TRADEOFFS.md.
- The per-child AI rate limit (20/minute default) bounds request rate, not dollar spend; a real
  budget cap was explicitly deferred, not forgotten — listed under "What I'd do with more time."
- Account deletion (Phase 5) was built backend-only; no mobile screen was added to call it, since
  the master spec's Phase 5 checklist describes the capability without mandating a specific mobile
  settings UI, and adding one unverified (no device to test a destructive confirmation flow on)
  felt riskier than leaving it backend-only with the gap stated plainly.
- Phase 6 was written as a plan document only (`docs/PHASE_6_PLAN.md`), per the master spec's own
  instruction to propose rather than build it, and because every Phase 6 item needs a real external
  credential, cloud account, or device this environment doesn't have.
