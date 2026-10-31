# API Specification

Base path: `/api/v1`. Full interactive docs at `/swagger-ui.html` when the API is running
(generated from the actual controllers via springdoc — this document is a human-readable summary
of the same reality, not a separate spec that can drift from the code).

All endpoints except `POST /api/v1/auth/**`, `/actuator/health`, and the Swagger/OpenAPI routes
require `Authorization: Bearer <accessToken>`. `{childId}` routes additionally require the token's
subject to own that child (enforced server-side; see ARCHITECTURE.md).

Errors use a consistent shape (see `interfaces/rest/common/ApiExceptionHandler`):
```json
{ "timestamp": "2026-10-26T00:00:00Z", "status": 404, "detail": "Child profile was not found" }
```

## Authentication

| Method | Path | Auth | Body | Response |
| --- | --- | --- | --- | --- |
| POST | `/auth/register` | No | `{email, password}` | 201, `{parentId, email, accessToken, refreshToken, tokenType}` |
| POST | `/auth/login` | No | `{email, password}` | 200, same shape as register |
| POST | `/auth/refresh` | No | `{refreshToken}` | 200, same shape — the presented refresh token is revoked and a new pair is issued |
| POST | `/auth/logout` | No | `{refreshToken}` | 204 — revokes the token; a no-op (still 204) if it's already unknown/revoked |
| DELETE | `/auth/me` | Yes | `{password}` | 204 — permanently deletes the authenticated parent's account; 401 if `password` doesn't match. Every child profile, their progress, rewards, and refresh tokens cascade-delete at the database level |

Password: 12–72 characters, required at registration. Login failure wording is identical whether
the email is unknown or the password is wrong. Auth endpoints are rate-limited (default 10
requests/minute/IP via Redis; falls back to an in-process counter if Redis is unreachable). Note: `/auth/me` requires
`Authorization: Bearer <accessToken>` like any other authenticated route — only
`register`/`login`/`refresh`/`logout` are exempt. A missing, expired, or invalid access token on an authenticated route gets
`401` (standard error shape) — the client's cue to call `/auth/refresh` or sign in again.

## Children

| Method | Path | Body | Response |
| --- | --- | --- | --- |
| POST | `/children` | `{displayName, birthDate, gradeLevel?, avatar?, learningPreferences?}` | 201, `{id, displayName, birthDate, gradeLevel, avatar, learningPreferences}` |
| GET | `/children` | — | 200, list of the above, ordered by display name |
| PATCH | `/children/{childId}` | `{displayName?, birthDate?, gradeLevel?, avatar?}` — omitted fields are unchanged | 200, the updated profile; 404 if the child is not this parent's. Progress, coins and badges are kept. |

`gradeLevel`/`avatar`/`learningPreferences` are optional — omitting them defaults to `GRADE_1` /
`FOX` / `[]`. Valid enum values: `gradeLevel` ∈ `{PRE_K, KINDERGARTEN, GRADE_1, GRADE_2, GRADE_3, GRADE_4, GRADE_5, GRADE_6}`;
`avatar` ∈ `{FOX, OWL, ROBOT, ASTRONAUT, DRAGON}`; `learningPreferences` ⊆ `{VISUAL, AUDITORY,
STORY, GAMES, REPETITION}`.

## Lesson catalog

| Method | Path | Response |
| --- | --- | --- |
| GET | `/children/{childId}/lessons` | 200, `[{code, subject, gradeLevel, order, title, description}]` — only lessons at the child's own grade level |
| GET | `/children/{childId}/lessons/{code}/set?number=` | 200, `{code, subject, title, description, setNumber, totalSets, completedAllSets, exercises: [...]}` — one set of 3 questions, picked at random and in random order on every call. While any of the lesson's questions are unanswered, the set is drawn only from those and `setNumber` follows the child's progress (answered / 3 + 1), so a returning child continues; once every question is answered, `completedAllSets` is `true` and sets are drawn from the whole lesson, with `number` (1-based, clamped) used only to label practice rounds. 404 if the child isn't this parent's or the lesson is unknown |
| GET | `/lessons/{code}` | 200, `{code, subject, title, description, exercises: [{id, order, prompt, choices}]}`; 404 if unknown |

**The list endpoint is child-scoped, not a bare catalog browse.** It used to be
`GET /api/v1/lessons` with no child context and no grade filtering at all — every child saw every
lesson regardless of age. Now it requires the token's parent to own `{childId}` (404 otherwise,
same `ChildNotFoundException` pattern as every other child-scoped endpoint) and returns only
lessons matching that child's `gradeLevel`. Lesson **detail** stays at the old ungated
`/lessons/{code}` path — a child only ever reaches it via a code from their own already-filtered
list, so there's no real exposure in leaving it open.

**`exercises` carries no answer-index field** — grading happens server-side (see "Exercise
evaluation" below). This is a Phase 2 change: the catalog used to embed `questions` with an
`answerIndex` the client graded itself; that shape no longer exists.

**Curriculum coverage**: Math and English, PRE_K through GRADE_6. Grade 1 has 17 lessons (9 Math +
8 English); every other grade has 19 (10 Math + 9 English). Every lesson has 6 questions, served
as two sets of 3. See
`docs/DATABASE_DESIGN.md` → "Curriculum scope".

## Exercise evaluation

| Method | Path | Body | Response |
| --- | --- | --- | --- |
| POST | `/children/{childId}/exercises/{exerciseId}/attempts` | `{submittedAnswerIndex}` | 201, `{correct, explanation, hint}` — `hint` is `null` when `correct` is `true` |

Records the attempt, updates the exercise's skill's progress counters, and recalculates the
parent lesson's completion/score from every exercise attempted so far. 404 if the exercise id
doesn't exist.

## Progress

| Method | Path | Response |
| --- | --- | --- |
| GET | `/children/{childId}/progress` | 200, `[{id, lessonCode, score, completed, updatedAt}]`, most recently updated first |

**There is no longer a `PUT` here.** A prior version let the client submit
`{score, completed}` directly for a lesson — removed in Phase 2 because nothing verified it
server-side (see RISKS_AND_TRADEOFFS.md). Progress is now a read-only view derived from exercise
attempts; completing a lesson for the **first time** (every exercise attempted at least once)
triggers a reward via the ledger below.

## Rewards

| Method | Path | Response |
| --- | --- | --- |
| GET | `/children/{childId}/rewards` | 200, `{coins, currentStreak, longestStreak, lastActivityDate}` |

`coins` is the sum of an append-only ledger (`reward_transactions`), not a stored counter — see
DATABASE_DESIGN.md.

## Badges

| Method | Path | Response |
| --- | --- | --- |
| GET | `/children/{childId}/badges` | 200, `[{badgeCode, awardedAt}]` |

Two badges exist today: `FIRST_STEPS` (first lesson ever completed) and `FIVE_DAY_STREAK` (a
5-day activity streak). Evaluated automatically after every reward-worthy event — there is no
separate "check for new badges" call.

## Parent dashboard

| Method | Path | Response |
| --- | --- | --- |
| GET | `/children/{childId}/dashboard` | 200, `{lessonsCompletedThisWeek, totalLessonsAttempted, averageScore, strongestSubject, weakestSubject, coins, currentStreak, longestStreak, recommendedNextLessonCode, recommendedNextLessonTitle}` |

`strongestSubject`/`weakestSubject` are derived from average score per subject across whatever
lessons the child has attempted; both are `null` if the child has no progress yet. This is
**measured activity**, not a validated mastery model — see "Mastery algorithm" in
`docs/DATABASE_DESIGN.md`. `recommendedNextLessonCode`/`Title` are the first catalog lesson, in
display order, the child hasn't completed yet (both `null` if every lesson is complete) — a plain
"next up" pointer, not a personalized or adaptive recommendation.

## AI tutor

| Method | Path | Body | Response |
| --- | --- | --- | --- |
| POST | `/children/{childId}/tutor/questions` | `{question (<= 500 chars), subject?, attempt (int, >= 0)}` | 201, `{strategy, explanation, suggestedNextActivity, refused}` |

`strategy` ∈ `{STEP_BY_STEP, STORY, REAL_LIFE_EXAMPLE, VISUAL_ANALOGY, GUIDED_QUESTION}`, selected
by `attempt % 5` — the mobile client increments `attempt` each time the child taps "try another
way." Falls back to a deterministic offline template if no `ANTHROPIC_API_KEY` is configured, or
if the real call fails. `refused` is `true` (with `strategy` meaningless/absent from the UI) when
the question fails the content safety check — in that case the AI client is never called at all.
`suggestedNextActivity` is a human-readable pointer at a lesson in the question's subject (or the
catalog's first lesson if no subject was given), `null` if the catalog has nothing to suggest.
Note: the master spec's example route shape (`/tutor/sessions/{sessionId}/messages`, implying a
stateful conversation) is not what's implemented — this remains a stateless per-question endpoint.
See DEVELOPMENT_PLAN.md Phase 4. Rate-limited per child (default 20 requests/minute via Redis;
falls back to an in-process counter if Redis is unreachable) — see SECURITY_AND_CHILD_SAFETY.md.

## Homework helper

| Method | Path | Body | Response |
| --- | --- | --- | --- |
| POST | `/children/{childId}/homework/questions` | `{questionText (<= 500 chars)}` | 201, `{steps: [string], finalHint, workedSteps?: [{explanation, work?}], finalAnswer?}` |
| POST | `/children/{childId}/homework/scans` | `{imageBase64}` — JPEG/PNG/WebP, <= 5 MB decoded | 200, `{questionText}` |

**Photo scanning** (`/scans`) only transcribes: it returns the question read off the photo
(<= 500 chars, so it can be sent to `/questions` unchanged) for the user to check and edit — it
does not return guidance itself. The image type is detected from its bytes (the client's claim is
ignored), and the photo is never stored or logged. Errors: 400 (missing, oversized, not
base64, or not a JPEG/PNG/WebP), 422 (no question found, or the transcription failed the content-safety
check), 503 (no vision provider configured, i.e. no `GEMINI_API_KEY`, or the provider call failed
— the client tells the user to type the question instead).

`/questions` returns a **worked solution** when an AI provider is configured: `workedSteps` (each
step's explanation plus `work`, the math and its result) and `finalAnswer`, pitched at the child's
grade. The offline fallback can't solve anything, so it omits both and returns general guidance
only. `steps`/`finalHint` are always present as a plain-text rendering for older clients. Same
offline/real-AI-with-fallback behavior and content-safety check as the tutor: an unsafe question
never reaches the AI client, and an unsafe or oversized real AI response falls back to the offline
template. Rate-limited per child, shared with the tutor endpoint's limiter and budget
(`/api/v1/children/{childId}/(tutor|homework)/`).

## Operational

| Method | Path | Notes |
| --- | --- | --- |
| GET | `/actuator/health` | Liveness/readiness; no auth |
| GET | `/v3/api-docs`, `/swagger-ui.html` | OpenAPI document and UI; no auth |

A request that exceeds its rate limit (auth endpoints, or the AI tutor/homework endpoints above,
including `/homework/scans`) receives `429 Too Many Requests` in the standard error shape above,
with a `Retry-After: 60` header.

## Not yet implemented (see docs/DEVELOPMENT_PLAN.md and docs/PHASE_6_PLAN.md for phasing)

- Any teacher-facing endpoint — out of MVP scope by design.
- A stateful tutor conversation resource matching the master spec's example route shape.
- Mobile UI for account deletion — the backend endpoint above exists; no screen calls it yet.
