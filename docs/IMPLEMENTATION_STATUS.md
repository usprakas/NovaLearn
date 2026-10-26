# Implementation Status

Last updated: this session (Phase 2 "Learning engine" + Phase 3 "Flutter application", following
the master-spec-alignment pass that did Phase 0/1).

## What exists coming into this session

Phase 0/1 complete: repo restructured into `backend/`/`mobile/`/`docs/`/`infrastructure/`, rotating
refresh tokens + Redis-backed auth rate limiting, `ChildProfile` extended with
grade/avatar/preferences. 40 backend unit tests, 7 mobile tests, both green. The lesson catalog was
still in-code (5 lessons, 2 subjects) and the mobile app still used plain `StatefulWidget`s.

## What this session did

### Phase 2 — Learning engine (backend)

- **Promoted the lesson catalog to the database**: `subjects`, `skills`, `lessons`, `exercises`,
  `exercise_choices` (migrations V5), seeded by V8 with exactly the five Math topics the master
  spec names (Counting and Number Recognition, Addition, Subtraction, Number Comparison, Simple
  Word Problems) — English content from an earlier pre-spec session was not carried forward.
  `application.catalog.LessonCatalogService` replaces the old in-code `LessonCatalog` with the
  same facade shape.
- **Server-side exercise grading, for real**: `ExerciseAnswerKey` (the correct answer index) is
  fetched only by `ExerciseEvaluationService` and never serialized into any controller response —
  `GET /lessons/{code}` now returns exercises with no answer index at all. `POST
  /children/{id}/exercises/{id}/attempts` records the attempt, updates `SkillProgress`, and
  triggers `ProgressService.recalculate`, which derives the lesson's score/completion from every
  exercise attempted so far (migrations V6).
- **Removed `PUT /children/{id}/progress/{lessonCode}`** — the endpoint that used to let a client
  set its own score/completion outright. This was the actual fix for the integrity gap flagged in
  RISKS_AND_TRADEOFFS.md in the previous pass, not a new parallel path left alongside the old one.
- **Rewards became an auditable ledger**: `reward_transactions` (migration V7) replaces the
  single mutable `coins` column; `RewardsService.award` is idempotent on
  `(referenceType, referenceId)`, checked in application code and enforced by a database unique
  constraint. `child_rewards` was renamed to `child_streaks` and lost its `coins` column in the
  same migration. Two badges (`FIRST_STEPS`, `FIVE_DAY_STREAK`) are evaluated automatically after
  every award via `BadgeService`.
- Added 24 new backend tests across `LessonCatalogServiceTest`, `ExerciseEvaluationServiceTest`,
  `BadgeServiceTest`, plus rewrote `ProgressServiceTest`, `RewardsServiceTest`, and
  `DashboardServiceTest` for the new collaborators.

### Phase 3 — Flutter application (mobile)

- Added `flutter_riverpod` and introduced `SessionController`
  (`features/auth/application/session_controller.dart`), a `StateNotifier<AsyncValue<Session?>>`
  owning restore/login/register/sign-out. `app.dart` and `AuthScreen` became
  `ConsumerWidget`/`ConsumerStatefulWidget`. See ADR 0003 for the explicit boundary: leaf tabs
  (`LessonListTab`, `TutorTab`, `HomeworkTab`, `ParentDashboard`) still receive `token`/`api` via
  constructor from `HomeScreen`, by deliberate choice.
- **Rewrote `LessonScreen`** for the new per-exercise flow: shows one exercise at a time, submits
  each answer via the new endpoint, shows immediate correct/incorrect + explanation + (if wrong) a
  hint, then "Next question"/"Finish lesson." The old whole-lesson client-side `LessonAttempt`
  scoring class is gone — there was nothing left for the client to grade.
- Updated `NovaLearnApi`/domain models for every Phase 2 API shape change: `Lesson.exercises` (no
  `answerIndex`), new `ExerciseRepository.submitAnswer`, `ProgressRepository` lost
  `recordProgress`, new `BadgesRepository`, `AuthSession`/`Session` gained `refreshToken`.
- `ParentDashboard` now also shows earned badges (plain chips, not a dedicated screen).
- `SessionStore` persists the refresh token; `AuthRepository` gained `refresh`/`logout` — but no
  automatic retry-after-refresh-on-401 was built (see RISKS_AND_TRADEOFFS.md).
- Replaced `lesson_attempt_test.dart` with `lesson_test.dart` (JSON parsing for the new shapes);
  updated `novalearn_api_test.dart` and `widget_test.dart` for the new request/response shapes and
  the Riverpod-wrapped `AuthScreen`.

## Commands actually executed, and their results

```sh
cd backend && ./mvnw -q clean test -Dtest='!PostgresIntegrationTest' -DfailIfNoTests=false
# -> 52 tests, 0 failures, 0 errors (run repeatedly through this session, after each change)

cd backend && ./mvnw clean verify
# -> 53 tests run, 52 pass, 1 error: PostgresIntegrationTest fails with
#    "IllegalState: Could not find a valid Docker environment." (expected — no Docker here)

# Sanity-checked V1-V8 by replaying them against H2 (PostgreSQL-compatibility mode) via a
# throwaway JDBC script in the scratchpad directory (deleted afterward, not part of the repo):
# -> "ALL MIGRATIONS APPLIED SUCCESSFULLY" after fixing one real bug the check caught (a
#    multi-line SQL comment containing a literal ';' confused the script's own comment-stripping
#    logic on the first attempt — fixed in the script, not the migration, which was correct).

cd mobile && flutter pub get && flutter analyze
# -> "No issues found!"

cd mobile && flutter test
# -> "All tests passed!" (9 tests)
```

No command was run and then assumed to pass without observing its output.

## Known issues / explicitly deferred

- No Testcontainers-backed integration test exercises the full exercise-attempt → lesson-completion
  → reward-ledger → badge flow end to end against a real database (only unit-tested with mocks) —
  no Docker available here to build and verify one.
- The mobile app's new per-exercise `LessonScreen` has never been run on a simulator/emulator or
  device — verified only via `flutter analyze`/`flutter test`, which don't exercise the actual UI.
- Automatic token refresh on a 401 is not implemented (see RISKS_AND_TRADEOFFS.md).
- AI output structured-validation/strict-schema/refusal-handling (Phase 4) still not implemented.

## Exact next action

Either: (a) pick up Phase 4's remaining AI-tutor hardening items (structured output validation,
per-session rate limiting on AI calls) now that a real learning-engine data model exists to anchor
tutor context against, or (b) if real Docker/device access becomes available, prioritize running
the Testcontainers integration test and the mobile app on an actual emulator before adding more
features — both are currently blind spots that only real tooling can close, not more code.
