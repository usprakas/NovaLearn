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
| Parent auth, child profiles, lesson progress | Real, tested, unchanged from Sprint 1/2 |
| Lesson catalog (5 lessons, 2 subjects) | Real, served from the backend; lives in code, not a DB table (see ARCHITECTURE.md) |
| Gamification (coins, streaks) | Real, persisted, tested, including day-boundary streak logic |
| Parent dashboard aggregation | Real, computed from live progress + rewards data |
| AI tutor | Real offline templates by default; real Anthropic API call if `ANTHROPIC_API_KEY` is set (untested against the live API here — no key provisioned) |
| Homework helper | Same pattern as the tutor. **Not OCR** — the input is typed text, never a photo. A real "homework scanner" needs a vision/OCR API this environment has no credential for |
| Voice input/output | Not built. Flutter's on-device `speech_to_text`/`flutter_tts` don't need a cloud key, but there is no emulator/device here to verify them on, so nothing was added rather than add unverified code |
| Teacher dashboard | Not built — the PRD itself marks this "(Future)", not MVP scope |
| AWS deployment, Cognito, CloudFront, S3 | Not built — no cloud credentials in this environment; the app runs via `docker compose` locally instead |
| Multi-language, AR, coding curricula | Not built — the PRD's own Year 2/3 roadmap, not MVP scope |

## Known limitations carried over from Sprint 1/2 (not new)

- **Lesson scoring is computed client-side.** The mobile app grades the attempt from questions it
  already has and submits a final score; nothing re-grades it server-side. Fine for an MVP with
  no adversarial users; a production product should grade server-side.
- **H2/local Postgres only** — `docker compose up` runs a single Postgres container with no backup,
  replication, or connection pooling tuning.

## New limitations introduced in this pass

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
- **No server-side rate limiting or budget cap on tutor/homework calls.** A child could spam
  questions; nothing throttles it. Fine for a demo, not for production (also relevant if
  `ANTHROPIC_API_KEY` were ever set — unbounded calls cost real money).

## Failure scenarios and how the system responds

| Scenario | Response |
| --- | --- |
| `ANTHROPIC_API_KEY` is unset or blank | `AiConfig` registers no `AiTextClient` bean; `TutorService`/`HomeworkService` fall back to deterministic offline templates automatically |
| The real Anthropic API call fails or returns a non-200 | `AnthropicTextClient` throws; `TutorService`/`HomeworkService` catch it and fall back to the deterministic offline template for that request rather than returning a 500 — see `fallsBackToTheOfflineTemplateWhenTheRealAiCallFails` / `fallsBackToOfflineGuidanceWhenTheRealAiCallFails` |
| A child/parent mismatch on any new endpoint | Every new service checks `ChildProfileRepository.belongsToParent` before doing anything and throws the shared `ChildNotFoundException` (mapped to 404), exactly like the original `ProgressService` |
| A lesson code doesn't exist in the catalog | `LessonCatalogController` throws `LessonNotFoundException`, mapped to 404 |
| A parent re-completes an already-completed lesson | `ProgressService` still updates the best score, but does **not** re-award coins or extend the streak a second time — see `doesNotRewardTwiceForReCompletingTheSameLesson` |
| Postgres is unreachable | Unchanged from Sprint 1: Spring Boot's datasource health check surfaces this via `/actuator/health`; no new failure handling was added for the new endpoints beyond the existing JPA/transaction boundaries |

## What I'd do with more time

- Move the lesson catalog to an admin-editable store once it needs to grow past a handful of lessons.
- Grade lessons server-side instead of trusting the client-submitted score.
- Add a real OCR integration (e.g., a cloud vision API) behind the same kind of swappable interface
  used for the tutor, once an API key is available.
- Add on-device voice input/output (`speech_to_text` + `flutter_tts`) and verify it on a real
  device or emulator — not added here because it could not be verified at all in this environment.
- Rate-limit and budget-cap the AI-backed endpoints before ever turning on a real API key.
- Build the teacher dashboard and the Year 2/3 roadmap items once the family-facing MVP has real usage data to justify them.
