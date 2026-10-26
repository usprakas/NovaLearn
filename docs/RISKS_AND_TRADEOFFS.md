# Risks and trade-offs

## Deliberate scope boundaries (stated up front, not discovered after the fact)

Building "everything" in the NovaLearn PRD literally would mean AWS infrastructure (ECS, RDS, S3,
CloudFront, Cognito), a real speech-to-text/text-to-speech pipeline, OCR over photographed
homework, and app-store publishing. None of those are available in this environment (no cloud
credentials, no vision/speech API key, no device/emulator, no app-store access), so instead of
faking them, this pass built real, working Phase 1-5 functionality (backend + mobile + lesson
engine + gamification) and wired the two genuinely AI-shaped features — the tutor and the homework
helper — behind a real swappable interface (`AiTextClient`) with a deterministic offline
implementation as the default and a real Anthropic Messages API client as the opt-in path.

## What's real vs. what's a stand-in

| Feature | Status |
| --- | --- |
| Parent auth, child profiles, lesson progress | Real, tested |
| Rotating, hashed refresh tokens + logout | Real, tested (`AuthServiceTest`) — see ARCHITECTURE.md |
| Redis-backed rate limiting on auth endpoints | Real; fails open if Redis is unreachable; not covered by an automated test (would need a real or embedded Redis) |
| Lesson catalog (5 lessons, 2 subjects) | Real, served from the backend; lives in code, not a DB table (see DATABASE_DESIGN.md) |
| Gamification (coins, streaks) | Real, persisted, tested, including day-boundary streak logic |
| Parent dashboard aggregation | Real, computed from live progress + rewards data |
| AI tutor | Real offline templates by default; real Anthropic API call if `ANTHROPIC_API_KEY` is set (untested against the live API here — no key provisioned) |
| Homework helper | Same pattern as the tutor. **Not OCR** — the input is typed text, never a photo. A real "homework scanner" needs a vision/OCR API this environment has no credential for |
| Richer curriculum schema (`Exercise`, `Skill`, `ExerciseAttempt`, reward ledger, badges, tutor sessions) | **Not built.** Scoped as Phase 2 — see DEVELOPMENT_PLAN.md. Today's schema is simpler (a single lesson-level progress row and a single rewards accumulator row, not an auditable ledger) |
| Riverpod state management on mobile | **Not built.** Decided (ADR 0003) but not yet implemented; the app still uses plain `StatefulWidget`/`FutureBuilder` |
| Voice input/output | Not built. Flutter's on-device `speech_to_text`/`flutter_tts` don't need a cloud key, but there is no emulator/device here to verify them on, so nothing was added rather than add unverified code |
| Teacher dashboard | Not built — the PRD itself marks this "(Future)", not MVP scope |
| AWS deployment, Cognito, CloudFront, S3 | Not built — no cloud credentials in this environment; the app runs via `docker compose` locally instead |
| Multi-language, AR, coding curricula | Not built — the PRD's own Year 2/3 roadmap, not MVP scope |

## Known limitations

- **Lesson scoring is computed client-side.** The mobile app grades the attempt from questions it
  already has and submits a final score; nothing re-grades it server-side. Fine for an MVP with
  no adversarial users; a production product should grade server-side.
- **`ChildProfile` still collects an exact `birthDate`, not a coarser age range**, even though the
  master spec's data-minimization principle ("avoid collecting unnecessary personal information
  from children") would favor the latter. Not changed in this pass because it would be a breaking
  change to the existing registration flow and mobile UI (a date picker); flagged here as a real
  tension to revisit, not silently resolved either way.
- **Coin/streak rules are simple and hardcoded** (10 coins per first completion, +5 for a perfect
  score, streak math based on calendar days in UTC). A real product would make these
  configurable/data-driven and probably timezone-aware per family, not UTC-fixed.
- **The tutor's "try another way" strategy rotation is client-tracked** (the mobile app increments
  an `attempt` counter and resends it) rather than server-tracked across a conversation — there is
  no server-side tutoring session or memory between questions. The PRD's "Learning memory" feature
  is not built.
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

## Failure scenarios and how the system responds

| Scenario | Response |
| --- | --- |
| `ANTHROPIC_API_KEY` is unset or blank | `AiConfig` registers no `AiTextClient` bean; `TutorService`/`HomeworkService` fall back to deterministic offline templates automatically |
| The real Anthropic API call fails or returns a non-200 | `AnthropicTextClient` throws; `TutorService`/`HomeworkService` catch it and fall back to the deterministic offline template for that request rather than returning a 500 — see `fallsBackToTheOfflineTemplateWhenTheRealAiCallFails` / `fallsBackToOfflineGuidanceWhenTheRealAiCallFails` |
| A child/parent mismatch on any new endpoint | Every new service checks `ChildProfileRepository.belongsToParent` before doing anything and throws the shared `ChildNotFoundException` (mapped to 404), exactly like the original `ProgressService` |
| A lesson code doesn't exist in the catalog | `LessonCatalogController` throws `LessonNotFoundException`, mapped to 404 |
| A parent re-completes an already-completed lesson | `ProgressService` still updates the best score, but does **not** re-award coins or extend the streak a second time — see `doesNotRewardTwiceForReCompletingTheSameLesson` |
| Postgres is unreachable | Spring Boot's datasource health check surfaces this via `/actuator/health`; no bespoke failure handling beyond the existing JPA/transaction boundaries |
| Redis is unreachable | The auth rate limiter logs a warning and allows the request rather than failing authentication — Redis is treated as optional, not load-bearing, for this MVP |
| A presented refresh token is expired, revoked, or unknown | `AuthService.refresh`/`logout` reject with the same generic `AuthenticationException` in all three cases, so a caller can't distinguish them |

## What I'd do with more time

- Move the lesson catalog to an admin-editable store once it needs to grow past a handful of lessons.
- Grade lessons server-side instead of trusting the client-submitted score.
- Build Phase 2's richer schema (`Exercise`, `Skill`, `ExerciseAttempt`, a `reward_transactions`
  ledger, badges) — see DATABASE_DESIGN.md for the sketch already written.
- Add a real OCR integration (e.g., a cloud vision API) behind the same kind of swappable interface
  used for the tutor, once an API key is available.
- Add on-device voice input/output (`speech_to_text` + `flutter_tts`) and verify it on a real
  device or emulator — not added here because it could not be verified at all in this environment.
- Add per-child/session rate limiting and a budget cap on the AI-backed endpoints specifically,
  before ever turning on a real API key in a shared environment.
- Migrate the mobile app to Riverpod (ADR 0003) before Phase 3 adds more screens.
- Add a scheduled cleanup job for expired/revoked refresh tokens.
- Build the teacher dashboard and the Year 2/3 roadmap items once the family-facing MVP has real usage data to justify them.
