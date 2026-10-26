# Database Design

PostgreSQL, Flyway-migrated, append-only (never edit a migration that may have already run — add
a new `V{n}__description.sql`).

## Current schema (V1–V4, implemented and tested)

```
parent_accounts
  id UUID PK
  email VARCHAR(320) UNIQUE NOT NULL
  password_hash VARCHAR(100) NOT NULL        -- BCrypt; plaintext is never stored
  role VARCHAR(20) NOT NULL CHECK (role = 'PARENT')

child_profiles
  id UUID PK
  parent_id UUID NOT NULL REFERENCES parent_accounts ON DELETE CASCADE
  display_name VARCHAR(60) NOT NULL
  birth_date DATE NOT NULL
  grade_level VARCHAR(20) NOT NULL DEFAULT 'GRADE_1'   -- added V4
  avatar VARCHAR(20) NOT NULL DEFAULT 'FOX'            -- added V4
  INDEX idx_child_profiles_parent_id (parent_id)

child_learning_preferences                              -- added V4
  child_id UUID NOT NULL REFERENCES child_profiles ON DELETE CASCADE
  preference VARCHAR(20) NOT NULL
  PK (child_id, preference)

lesson_progress
  id UUID PK
  child_id UUID NOT NULL REFERENCES child_profiles ON DELETE CASCADE
  lesson_code VARCHAR(100) NOT NULL          -- opaque; no FK to a catalog table, see below
  score INTEGER NOT NULL CHECK (0-100)
  completed BOOLEAN NOT NULL DEFAULT FALSE
  updated_at TIMESTAMPTZ NOT NULL
  UNIQUE (child_id, lesson_code)
  INDEX idx_lesson_progress_child_id (child_id)

child_rewards
  child_id UUID PK REFERENCES child_profiles ON DELETE CASCADE
  coins INTEGER NOT NULL DEFAULT 0 CHECK (>= 0)
  current_streak INTEGER NOT NULL DEFAULT 0 CHECK (>= 0)
  longest_streak INTEGER NOT NULL DEFAULT 0 CHECK (>= 0)
  last_activity_date DATE

refresh_tokens                                          -- added V3
  id UUID PK
  parent_id UUID NOT NULL REFERENCES parent_accounts ON DELETE CASCADE
  token_hash VARCHAR(64) UNIQUE NOT NULL     -- SHA-256 hex of the raw token; raw value never stored
  issued_at TIMESTAMPTZ NOT NULL
  expires_at TIMESTAMPTZ NOT NULL
  revoked BOOLEAN NOT NULL DEFAULT FALSE
  INDEX idx_refresh_tokens_parent_id (parent_id)
```

### Why `lesson_progress.lesson_code` has no foreign key

This was a deliberate Sprint 1 decision, carried forward here rather than reversed: lesson content
lives in `application.catalog.LessonCatalog` (in-code), not a database table, so curriculum can
expand without a schema migration. At 5 lessons across 2 subjects this is the right size. It stops
being the right size once the catalog needs admin editing or grows past a few dozen lessons — at
that point, promote it to the `curriculum_units` / `lessons` tables sketched below (Phase 2) and
add the foreign key then.

## Planned schema for Phase 2 ("Learning engine") — not yet implemented

This master spec asks for a fuller entity model: `Subject`, `CurriculumUnit`, `Lesson`, `Skill`,
`Exercise`, `ExerciseAttempt`, `LearningSession`, `SkillProgress`, `RewardTransaction` (an auditable
ledger replacing the current single-row `child_rewards` accumulator), `Badge`, `ChildBadge`,
`TutorSession`, `TutorMessage`. None of these tables exist yet. Sketch (subject to revision when
Phase 2 actually starts):

```
subjects(id, code, name)
curriculum_units(id, subject_id FK, grade_level, title, display_order)
lessons(id, curriculum_unit_id FK, code, title, description, display_order)
skills(id, subject_id FK, code, name)
exercises(id, lesson_id FK, skill_id FK, prompt, choices JSONB, answer_index, display_order)
exercise_attempts(id, child_id FK, exercise_id FK, submitted_answer_index, is_correct, attempted_at)
learning_sessions(id, child_id FK, started_at, ended_at)
skill_progress(id, child_id FK, skill_id FK, mastery_score, attempts_count, last_attempt_at)
reward_transactions(id, child_id FK, delta_coins, reason, reference_type, reference_id, created_at)
badges(id, code, name, description, criteria)
child_badges(child_id FK, badge_id FK, awarded_at, PK(child_id, badge_id))
tutor_sessions(id, child_id FK, subject_id FK, started_at)
tutor_messages(id, tutor_session_id FK, role, content, strategy, created_at)
```

Rationale for `reward_transactions` as a ledger rather than mutating `child_rewards` directly:
an auditable append-only ledger (as the spec requires — "store reward transactions in an auditable
ledger") lets you reconstruct *why* a child has N coins, not just the current total, and makes
duplicate-reward prevention a query ("has a transaction with this reference_id already been
recorded?") rather than an implicit side effect buried in service logic.

## Mastery algorithm — explicitly provisional

There is no mastery algorithm implemented yet (it belongs to Phase 2's `skill_progress` work).
When one is built: keep it simple and transparent (e.g. a rolling accuracy rate over the last N
attempts per skill, with a minimum attempt count before reporting anything), document its exact
formula next to the code, and do not claim it reliably measures a child's overall ability from a
handful of answers — report it to parents as "recent practice accuracy," not "mastery."

## Retention and deletion (required by the master spec; not yet implemented as code)

- **Child profiles**: deleting a `parent_accounts` row cascades to `child_profiles`,
  `lesson_progress`, `child_rewards`, and `child_learning_preferences` via `ON DELETE CASCADE`.
  There is no API endpoint yet for a parent to delete their own account or a child profile — only
  the cascade behavior exists at the schema level. A delete-account endpoint is a Phase 5
  ("hardening") item.
- **Refresh tokens**: revoked/expired rows are kept (not deleted) as an audit trail, per
  `AuthService`'s design. A scheduled cleanup job to purge long-expired, already-revoked tokens
  does not exist yet — on a long-running production deployment this table grows unboundedly. Noted
  as a limitation, not fixed here.
- **Homework images**: not applicable yet — homework help is text-only in this phase (no OCR, no
  image upload, no S3 adapter). When OCR is built (Phase 6), uploaded images must go to private S3
  storage with short-lived signed URLs, as the spec requires, and a retention policy must be
  defined before that feature ships.
- **Tutor conversations**: not persisted at all today — each tutor request is stateless (the
  mobile app tracks the `attempt` counter client-side; nothing server-side remembers prior
  messages). This means there is currently nothing to retain or delete for tutor conversations,
  which is the simplest possible privacy posture, but also means `TutorSession`/`TutorMessage`
  (Phase 2) will need a retention policy defined before they ship.

**No legal compliance claim is made here.** Parental consent requirements, applicable children's
privacy laws (e.g. COPPA in the US), app-store policies, and any education-data regulations must
be reviewed by qualified counsel before launch; this document describes the technical retention
mechanics only.
