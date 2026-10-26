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

Password: 12–72 characters, required at registration. Login failure wording is identical whether
the email is unknown or the password is wrong. Auth endpoints are rate-limited (default 10
requests/minute/IP via Redis; fails open if Redis is unreachable).

## Children

| Method | Path | Body | Response |
| --- | --- | --- | --- |
| POST | `/children` | `{displayName, birthDate, gradeLevel?, avatar?, learningPreferences?}` | 201, `{id, displayName, birthDate, gradeLevel, avatar, learningPreferences}` |
| GET | `/children` | — | 200, list of the above, ordered by display name |

`gradeLevel`/`avatar`/`learningPreferences` are optional — omitting them defaults to `GRADE_1` /
`FOX` / `[]` so the current mobile client (which only sends `displayName`/`birthDate`) keeps
working unmodified. Valid enum values: `gradeLevel` ∈ `{PRE_K, KINDERGARTEN, GRADE_1, GRADE_2,
GRADE_3}`; `avatar` ∈ `{FOX, OWL, ROBOT, ASTRONAUT, DRAGON}`; `learningPreferences` ⊆ `{VISUAL,
AUDITORY, STORY, GAMES, REPETITION}`.

## Lesson catalog

| Method | Path | Response |
| --- | --- | --- |
| GET | `/lessons` | 200, `[{code, subject, order, title, description}]` |
| GET | `/lessons/{code}` | 200, `{code, subject, title, description, questions: [{prompt, choices, answerIndex}]}`; 404 if unknown |

Scoring is computed client-side from the fetched questions and submitted as a final score via the
progress endpoint below — see `docs/RISKS_AND_TRADEOFFS.md` for why that is a known limitation,
not an oversight.

## Progress

| Method | Path | Body | Response |
| --- | --- | --- | --- |
| PUT | `/children/{childId}/progress/{lessonCode}` | `{score (0-100), completed}` | 200, `{id, lessonCode, score, completed, updatedAt}` — keeps the higher of the previous/new score and the OR of previous/new `completed` |
| GET | `/children/{childId}/progress` | — | 200, list of the above, most recently updated first |

Completing a lesson for the **first time** (transition from not-completed to completed) triggers a
reward via `RewardsService`; re-completing an already-completed lesson does not re-award.

## Rewards

| Method | Path | Response |
| --- | --- | --- |
| GET | `/children/{childId}/rewards` | 200, `{coins, currentStreak, longestStreak, lastActivityDate}` |

## Parent dashboard

| Method | Path | Response |
| --- | --- | --- |
| GET | `/children/{childId}/dashboard` | 200, `{lessonsCompletedThisWeek, totalLessonsAttempted, averageScore, strongestSubject, weakestSubject, coins, currentStreak, longestStreak}` |

`strongestSubject`/`weakestSubject` are derived from average score per subject across whatever
lessons the child has attempted; both are `null` if the child has no progress yet. This is
**measured activity**, not a validated mastery model — see the "Mastery algorithm" section of
`docs/DATABASE_DESIGN.md`.

## AI tutor

| Method | Path | Body | Response |
| --- | --- | --- | --- |
| POST | `/children/{childId}/tutor/questions` | `{question, subject?, attempt (int, >= 0)}` | 201, `{strategy, explanation}` |

`strategy` ∈ `{STEP_BY_STEP, STORY, REAL_LIFE_EXAMPLE}`, selected by `attempt % 3` — the mobile
client increments `attempt` each time the child taps "try another way," so repeated questions
rotate through explanation styles instead of repeating the same one. Falls back to a deterministic
offline template if no `ANTHROPIC_API_KEY` is configured, or if the real call fails. The master
spec's full strategy set (`VISUAL_ANALOGY`, `GUIDED_QUESTION` in addition to the three implemented)
and structured next-activity suggestions are not yet implemented — see
`docs/DEVELOPMENT_PLAN.md`.

## Homework helper

| Method | Path | Body | Response |
| --- | --- | --- | --- |
| POST | `/children/{childId}/homework/questions` | `{questionText}` | 201, `{steps: [string], finalHint}` |

Text-in only — **there is no OCR or image upload**. The mobile screen asks the parent/child to type
the question from the worksheet. Same offline/real-AI-with-fallback behavior as the tutor.

## Operational

| Method | Path | Notes |
| --- | --- | --- |
| GET | `/actuator/health` | Liveness/readiness; no auth |
| GET | `/v3/api-docs`, `/swagger-ui.html` | OpenAPI document and UI; no auth |

## Not yet implemented (see docs/DEVELOPMENT_PLAN.md for phasing)

- Exercise submission as its own resource (`ExerciseAttempt`) distinct from the current
  lesson-level `PUT .../progress/{lessonCode}` — Phase 2.
- A reward-transaction ledger endpoint and badges — Phase 2.
- Homework image upload (`POST .../homework/uploads` + S3) and OCR — Phase 6.
- Any teacher-facing endpoint — out of MVP scope by design.
