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

Curriculum content was originally narrowed to exactly the five Math topics the master spec names
(Counting, Addition, Subtraction, Comparison, Word Problems), Grade 1 only. **That scope was later
explicitly expanded by the user**, beyond the master spec's original MVP boundary, to cover every
grade from Pre-K through Grade 6, in both Math and English — see "Multi-grade curriculum
expansion" below and "Curriculum scope" in DATABASE_DESIGN.md.

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
| Account deletion | ✅ `DELETE /api/v1/auth/me`, password-reconfirmed, cascades to all child data at the DB level, **and a mobile Account screen (password-confirm dialog, danger-zone styling) that calls it** |
| Correlation-ID request logging | ✅ `CorrelationIdFilter`, echoed in `X-Correlation-Id` |
| Broader error-handling/logging pass | ✅ every `FutureBuilder` error branch across the app (lesson list, dashboard, child picker, tutor, homework, session restore) now shows a friendly message plus a retry action instead of a bare stack-trace-adjacent string — see `core/widgets/error_state.dart` |
| Accessibility pass | ✅ a real code-level pass, not just documentation: found and fixed two genuine WCAG non-text-contrast failures (the green subject icon and amber coin icon both measured under 3:1 against their own tinted backgrounds — recalculated and replaced), found and fixed that the app had no dark-theme/`themeMode` wiring at all (always rendered light regardless of the system setting), confirmed every interactive control has a tooltip/semantic label, and merged the dashboard metric cards' value+label into one screen-reader phrase. Still not done: an actual screen-reader (VoiceOver/TalkBack) walkthrough on a physical device — Chrome's accessibility tree isn't the same surface. |
| Performance pass | ⬜ not done — no load testing or query-plan review was performed; out of scope without real traffic patterns to test against |

## Phase 6 — Future extensions — 🟡 one item shipped on explicit request; the rest is a written plan

Homework OCR, additional subjects/grades, a teacher dashboard, subscription billing, and AWS
infrastructure-as-code are a plan only (`docs/PHASE_6_PLAN.md`), per the master spec's own
instruction to propose rather than build Phase 6, and because every one of those needs a real
external credential, cloud account, or device this environment doesn't have. See also
`infrastructure/README.md`.

**Speech-to-text / text-to-speech was explicitly requested and built** — the plan had already
flagged this as the one Phase 6 item not blocked by a missing credential (on-device packages,
or the browser's Web Speech API on web). A shared `VoiceAssistant` helper
(`core/voice/voice_assistant.dart`) wraps `speech_to_text`/`flutter_tts`; a mic button in the
tutor/homework question fields fills the text by voice, and a speaker button reads an answer
aloud. Verified live against a real backend in Chrome — not yet run on an actual iOS/Android
device. Required platform permissions were added
(`RECORD_AUDIO` on Android, `NSMicrophoneUsageDescription`/`NSSpeechRecognitionUsageDescription`
on iOS) even though they couldn't be exercised here.

**A second AI provider adapter (Gemini) was also added**, alongside Anthropic, once a real
(free-tier) Gemini key became available mid-session — not originally part of the Phase 6 plan,
but a natural extension of the existing provider-independent `AiTextClient` port. See
`docs/RISKS_AND_TRADEOFFS.md` for the real trade-off this comes with (free-tier content is used
to improve Google's products).

## Multi-grade curriculum expansion — ✅ done, beyond the master spec's original MVP scope

The master spec scoped the MVP to Grade 1 Math only. The user later explicitly asked to expand
this to every grade from Pre-K through Grade 6, in both Math and English — a deliberate,
requested scope change, not a reinterpretation of the original spec.

**Architecture** (prerequisite for any of the content below):
- `GradeLevel` extended from `PRE_K..GRADE_3` to the full `PRE_K..GRADE_6`.
- Fixed a real, previously-flagged gap: lessons were never filtered by grade at all — every child
  saw every lesson regardless of age (`docs/PHASE_6_PLAN.md` had already called this out as
  something to fix before adding more grades). `lessons` gained a `grade_level` column; the lesson
  *list* endpoint moved from an ungated `GET /api/v1/lessons` to a child-scoped, grade-filtered
  `GET /api/v1/children/{childId}/lessons`. `DashboardService`'s "recommended next" and
  `TutorService`'s "suggested next activity" were both updated to respect the child's grade too.
- `ENGLISH` added as a second subject alongside `MATH`.
- Mobile: found the "Add a child" dialog never sent `gradeLevel` at all, so every child defaulted
  to `GRADE_1` regardless of real age — fixed with a grade picker in the dialog.

**Content**: 7 grade batches (Pre-K, Kindergarten, Grade 2, Grade 3, Grade 4, Grade 5, Grade 6),
each with 9 Math + 8 English lessons (3 exercises per lesson) — 17 lessons/grade, matching the
"comprehensive" depth the user asked for. Grade 1 was deliberately left at its original 5 lessons
rather than rewritten to match (see "Curriculum scope" in `docs/DATABASE_DESIGN.md` for why).

**How this was verified, honestly**: this was *not* written in one pass and assumed correct.
Each grade's migration was applied against the running local demo backend (H2 in
PostgreSQL-compatibility mode) individually, confirming the migration ran cleanly, the lesson
list for a child at that grade returned exactly the expected lessons, and at least one real
exercise submission (including apostrophe-heavy content, e.g. contractions) graded correctly
end-to-end — before moving on to the next grade. A final regression pass confirmed all 8 grade
levels simultaneously return the correct, non-overlapping lesson sets. 74/74 backend tests passing
throughout.

**Not done as part of this**: the curriculum content itself has not been reviewed by anyone with
elementary-education subject-matter expertise — `docs/PHASE_6_PLAN.md` had already flagged that
real curriculum content needs that kind of review before being trusted in front of real children,
and that still applies here; this is a good-faith, standard-progression starting point, not a
credentialed curriculum.

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
