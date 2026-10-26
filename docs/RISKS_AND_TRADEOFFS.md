# Risks and trade-offs

## Deliberate scope boundaries (stated up front, not discovered after the fact)

Building "everything" in the NovaLearn PRD literally would mean AWS infrastructure (ECS, RDS, S3,
CloudFront, Cognito), a real speech-to-text/text-to-speech pipeline, OCR over photographed
homework, and app-store publishing. None of those are available in this environment (no cloud
credentials, no vision/speech API key, no device/emulator, no app-store access), so instead of
faking them, this pass built real, working Phase 1–3 functionality (backend + learning engine +
mobile) and wired the two genuinely AI-shaped features — the tutor and the homework helper —
behind a real swappable interface (`AiTextClient`) with a deterministic offline implementation as
the default and a real Anthropic Messages API client as the opt-in path.

## What's real vs. what's a stand-in

| Feature | Status |
| --- | --- |
| Parent auth, child profiles, lesson progress | Real, tested |
| Rotating, hashed refresh tokens + logout | Real, tested (`AuthServiceTest`) — see ARCHITECTURE.md |
| Redis-backed rate limiting on auth endpoints | Real; fails open if Redis is unreachable; not covered by an automated test (would need a real or embedded Redis) |
| Lesson catalog (5 Math lessons, DB-backed) | Real; promoted from in-code to `lessons`/`exercises` tables once exercises needed server-side-only identities — see DATABASE_DESIGN.md |
| **Server-side exercise grading** | Real: the answer index is never serialized to the client; `ExerciseEvaluationService` is the only code path that ever reads it |
| Gamification: coins (ledger), streaks, badges | Real, persisted, tested, including day-boundary streak logic and idempotent award-on-retry |
| Parent dashboard aggregation | Real, computed from live progress + rewards data |
| AI tutor | Real offline templates by default; real Anthropic API call if `ANTHROPIC_API_KEY` is set (untested against the live API here — no key provisioned) |
| Homework helper | Same pattern as the tutor. **Not OCR** — the input is typed text, never a photo |
| Riverpod state management on mobile | Real, but scoped to the app-wiring layer (session/auth) — see ADR 0003. Leaf-screen widgets still receive dependencies via constructor by deliberate choice |
| Voice input/output | Not built. Flutter's on-device `speech_to_text`/`flutter_tts` don't need a cloud key, but there is no emulator/device here to verify them on, so nothing was added rather than add unverified code |
| Teacher dashboard | Not built — the PRD itself marks this "(Future)", not MVP scope |
| AWS deployment, Cognito, CloudFront, S3 | Not built — no cloud credentials in this environment; the app runs via `docker compose` locally instead |
| Multi-language, AR, coding curricula | Not built — the PRD's own Year 2/3 roadmap, not MVP scope |

## Known limitations

- **`ChildProfile` still collects an exact `birthDate`, not a coarser age range**, even though the
  master spec's data-minimization principle ("avoid collecting unnecessary personal information
  from children") would favor the latter. Not changed because it would be a breaking change to the
  existing registration flow and mobile UI (a date picker); flagged here as a real tension to
  revisit, not silently resolved either way.
- **Coin/streak/badge rules are simple and hardcoded** (10 coins per first completion, +5 for a
  perfect score, streak math based on calendar days in UTC, exactly two badges with fixed
  criteria). A real product would make these configurable/data-driven and probably timezone-aware
  per family, not UTC-fixed.
- **The tutor's "try another way" strategy rotation is client-tracked** (the mobile app increments
  an `attempt` counter and resends it) rather than server-tracked across a conversation — there is
  no server-side tutoring session or memory between questions, and the master spec's example route
  shape (`/tutor/sessions/{sessionId}/messages`) implying one was never adopted. The PRD's
  "Learning memory" feature is not built.
- **The homework helper's AI-response parsing is a best-effort newline split**, not structured
  output from the model. If a real Anthropic response doesn't format as expected, the parsing
  falls back to treating the whole response as one step plus a generic hint rather than failing —
  reasonable, but worth knowing it is heuristic, not a contract with the model.
- **No per-child or per-session rate limiting or budget cap on tutor/homework calls specifically**
  — only the IP-based limit on the auth endpoints exists. A child could spam questions; nothing
  throttles that today. Do not enable a real `ANTHROPIC_API_KEY` in a shared environment until
  this is addressed (unbounded calls cost real money) — see SECURITY_AND_CHILD_SAFETY.md.
- **No scheduled cleanup of expired/revoked refresh tokens** — the table grows unboundedly in a
  long-running deployment.
- **No automatic silent token refresh.** The mobile client stores the refresh token and the backend
  endpoint works, but nothing retries a request after a 401 by calling refresh first — a parent
  whose access token expires mid-session has to sign in again. A deliberate scope cut, not an
  oversight: a correct retry-with-refresh interceptor needs care around concurrent requests
  refreshing simultaneously, and building it unverified felt worse than not building it.
- **Mastery is a plain accuracy ratio** (`correctCount / attemptsCount`), not surfaced to parents
  yet beyond the existing subject-level strongest/weakest signal. See "Mastery algorithm" in
  DATABASE_DESIGN.md for why it should stay this simple even when it is surfaced.
- **Flyway migrations V5–V8 (the Phase 2 schema) were sanity-checked by replaying them against H2
  in PostgreSQL-compatibility mode**, not a real Postgres — there is no Docker in this environment.
  This caught real syntax issues during authoring (see TESTING.md) but is not equivalent to the
  Testcontainers-based `PostgresIntegrationTest` CI runs with real Postgres.

## Failure scenarios and how the system responds

| Scenario | Response |
| --- | --- |
| `ANTHROPIC_API_KEY` is unset or blank | `AiConfig` registers no `AiTextClient` bean; `TutorService`/`HomeworkService` fall back to deterministic offline templates automatically |
| The real Anthropic API call fails or returns a non-200 | `AnthropicTextClient` throws; `TutorService`/`HomeworkService` catch it and fall back to the deterministic offline template for that request rather than returning a 500 |
| A child/parent mismatch on any endpoint | Every service checks `ChildProfileRepository.belongsToParent` before doing anything and throws the shared `ChildNotFoundException` (mapped to 404) |
| A lesson or exercise id doesn't exist | `LessonNotFoundException` / `ExerciseNotFoundException`, both mapped to 404 |
| A child resubmits an already-attempted exercise | Recorded as a new `ExerciseAttempt` row (useful for retry practice); lesson completion only requires having attempted each exercise at least once, so this is harmless, not double-counted toward completion |
| A reward is requested twice for the same event (client retry) | `RewardsService.award` checks `existsByReferenceTypeAndReferenceId` first, and a database unique constraint catches any race the application check misses — either way, a second award is a silent no-op, not an error |
| Postgres is unreachable | Spring Boot's datasource health check surfaces this via `/actuator/health`; no bespoke failure handling beyond the existing JPA/transaction boundaries |
| Redis is unreachable | The auth rate limiter logs a warning and allows the request rather than failing authentication — Redis is treated as optional, not load-bearing, for this MVP |
| A presented refresh token is expired, revoked, or unknown | `AuthService.refresh`/`logout` reject with the same generic `AuthenticationException` in all three cases, so a caller can't distinguish them |

## What I'd do with more time

- Move the lesson catalog to an admin-editable store once it needs to grow past a handful of lessons.
- Add a real OCR integration behind the same kind of swappable interface used for the tutor, once
  an API key is available.
- Add on-device voice input/output (`speech_to_text` + `flutter_tts`) and verify it on a real
  device or emulator.
- Add per-child/session rate limiting and a budget cap on the AI-backed endpoints specifically,
  before ever turning on a real API key in a shared environment.
- Build a stateful tutor-session resource (closer to the master spec's example route) with real
  "learning memory" across a conversation.
- Add automatic silent token refresh on a 401, with a single-flight guard against concurrent
  refresh attempts.
- Add a scheduled cleanup job for expired/revoked refresh tokens.
- Surface per-skill mastery to parents, keeping the same honest framing as today's subject-level
  signal.
- Build the teacher dashboard and the Year 2/3 roadmap items once the family-facing MVP has real
  usage data to justify them.
