# NovaLearn Architecture

## Scope

Sprint 1 established the secure learning foundation: parent registration/login, child profiles,
and durable per-lesson progress. Sprint 2 added the Flutter mobile client. This pass ("build
everything" against the original PRD's Phase 1-5 scope) adds:

- A multi-lesson catalog across two subjects (Math, English) instead of one hardcoded lesson.
- Gamification: coins and day-streaks, awarded when a lesson is completed for the first time.
- An AI tutor a child can ask questions, with "try another way" rotating through explanation
  strategies (step-by-step, story, real-life example).
- A homework helper that walks through a typed question step by step without just giving the answer.
- A parent dashboard that aggregates progress, rewards, and a strongest/weakest subject signal.

The first client remains a Grade 1 Math/English experience; lesson codes stay opaque so curriculum
can expand without a schema change (the catalog itself lives in code, not a database table — see
"Key decisions" below).

**What this intentionally does not include**, and why — see RISKS_AND_TRADEOFFS.md for the full
list: real OCR/image-based homework scanning, voice input/output, AWS deployment (ECS/RDS/S3/
CloudFront/Cognito), a teacher dashboard (the PRD itself marks this "(Future)"), and multi-language/
AR/coding curricula (the PRD's own Year 2/3 roadmap, not MVP scope).

## Boundaries

| Layer | Responsibility |
| --- | --- |
| `domain` | Stable domain concepts (`Role`, `ChildProfile`, `LessonProgress`, `LessonDefinition`, `ChildRewards`, `TutorAnswer`, `HomeworkGuidance`, `ChildDashboard`). |
| `application` | Use cases and ports. No Spring Data or HTTP dependency, except the `ai` package's port interface, which infrastructure implements. |
| `infrastructure` | JPA persistence, JWT/password implementations, and the real Anthropic HTTP client. |
| `interfaces` | REST request/response models, controllers, and error translation. |
| `config` | Security, OpenAPI, Clock, and AI-client wiring. |

The REST layer never exposes persistence entities. Every child-scoped operation is parent-scoped;
ownership is checked in the application service (via `ChildProfileRepository.belongsToParent`)
before any read or write — this is how `RewardsService`, `TutorService`, `HomeworkService`, and
`DashboardService` all guard access, exactly like the original `ProgressService`.

## API

| Method | Path | Authentication | Purpose |
| --- | --- | --- | --- |
| POST | `/api/v1/auth/register` | No | Register a parent and receive a JWT. |
| POST | `/api/v1/auth/login` | No | Authenticate a parent. |
| POST | `/api/v1/children` | Bearer JWT | Create a child profile. |
| GET | `/api/v1/children` | Bearer JWT | List the authenticated parent's children. |
| GET | `/api/v1/lessons` | Bearer JWT | List the lesson catalog. |
| GET | `/api/v1/lessons/{code}` | Bearer JWT | Get one lesson's full content, including questions. |
| PUT | `/api/v1/children/{childId}/progress/{lessonCode}` | Bearer JWT | Upsert lesson progress. |
| GET | `/api/v1/children/{childId}/progress` | Bearer JWT | List a child's learning progress. |
| GET | `/api/v1/children/{childId}/rewards` | Bearer JWT | Coins, current streak, longest streak. |
| GET | `/api/v1/children/{childId}/dashboard` | Bearer JWT | Weekly completions, average score, strongest/weakest subject, rewards. |
| POST | `/api/v1/children/{childId}/tutor/questions` | Bearer JWT | Ask the AI tutor a question. |
| POST | `/api/v1/children/{childId}/homework/questions` | Bearer JWT | Get guided homework steps for a typed question. |

Swagger UI is available at `/swagger-ui.html`; the health probe is `/actuator/health`.

## Key decisions

- **The lesson catalog lives in code (`LessonCatalog`), not a database table.** This continues the
  Sprint 1 decision that lesson codes stay opaque so curriculum can expand without a schema
  change; `lesson_progress.lesson_code` has no foreign key to a catalog table by design. A
  production catalog with hundreds of lessons would move to a CMS or admin-editable table — five
  lessons in two subjects does not justify that yet.
- **Lesson scoring is computed client-side**, same as the original design: the mobile app grades
  the attempt from the questions it already fetched and submits the final score. This is a
  deliberate carry-over, not a new gap, but worth stating plainly: a production product would
  grade server-side so a modified client can't submit an inflated score. See RISKS_AND_TRADEOFFS.md.
- **Rewards are recalculated, not just incremented, on every completion** — `RewardsService` reads
  the current streak/coins, computes the next streak from the last activity date (same day = no
  change, consecutive day = +1, gap = reset to 1, tracking the longest streak separately), and
  persists the result. A `Clock` is injected (not `Instant.now()`/`LocalDate.now()` directly) so
  streak transitions are deterministically testable across day boundaries.
- **The AI tutor and homework helper share one swappable port** (`AiTextClient`), wired by
  `AiConfig`: if `ANTHROPIC_API_KEY` is set, a real Anthropic Messages API call is used; otherwise
  the services fall back to deterministic, child-safe offline templates. This mirrors the pattern
  used in the companion `url-shortener-agentic` project — same idea, same honesty about what's
  actually been exercised (see RISKS_AND_TRADEOFFS.md: the real path is implemented but untested
  in this environment, since no key is provisioned here).
- **Homework help is text-in, not image-in.** The PRD's "homework scanner" implies OCR over a photo;
  this environment has no vision/OCR API credential, so the mobile screen asks the parent or child
  to type the question instead of pretending to scan a photo. Faking OCR would be worse than not
  having it.

## Test strategy

Unit tests cover the important use-case decisions for every slice: email normalization, duplicate
registration, generic authentication failure, child normalization, ownership enforcement,
non-regressing lesson progress, catalog lookups, streak/coin arithmetic (including day-boundary
edge cases), AI-client fallback vs. real-client usage for both tutor and homework, and dashboard
aggregation (including the empty-progress case). See TESTING.md for exact counts and what's not
covered. The Testcontainers integration test verifies Flyway against a real PostgreSQL instance —
it requires Docker and was not run in this authoring environment (no Docker available here); CI
runs it on every push.
