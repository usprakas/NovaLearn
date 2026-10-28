# Database Design

PostgreSQL, Flyway-migrated, append-only (never edit a migration that may have already run — add
a new `V{n}__description.sql`). Current version: V8. Sanity-checked by replaying all eight
migrations against H2 in PostgreSQL-compatibility mode (no Docker/Postgres available in this
authoring environment — see TESTING.md); not a substitute for the real Postgres Testcontainers run
CI performs.

## Schema

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
  grade_level VARCHAR(20) NOT NULL DEFAULT 'GRADE_1'   -- V4
  avatar VARCHAR(20) NOT NULL DEFAULT 'FOX'            -- V4
  INDEX idx_child_profiles_parent_id (parent_id)

child_learning_preferences                              -- V4
  child_id UUID NOT NULL REFERENCES child_profiles ON DELETE CASCADE
  preference VARCHAR(20) NOT NULL
  PK (child_id, preference)

refresh_tokens                                          -- V3
  id UUID PK
  parent_id UUID NOT NULL REFERENCES parent_accounts ON DELETE CASCADE
  token_hash VARCHAR(64) UNIQUE NOT NULL     -- SHA-256 hex of the raw token; raw value never stored
  issued_at TIMESTAMPTZ NOT NULL
  expires_at TIMESTAMPTZ NOT NULL
  revoked BOOLEAN NOT NULL DEFAULT FALSE
  INDEX idx_refresh_tokens_parent_id (parent_id)

-- Catalog (V5), seeded by V8 (Grade 1 Math) through V16 (Grade 6) — see "Curriculum scope" below
subjects
  code VARCHAR(20) PK
  name VARCHAR(100) NOT NULL

skills
  code VARCHAR(20) PK
  subject_code VARCHAR(20) NOT NULL REFERENCES subjects
  name VARCHAR(100) NOT NULL

lessons
  id UUID PK
  code VARCHAR(100) UNIQUE NOT NULL
  subject_code VARCHAR(20) NOT NULL REFERENCES subjects
  grade_level VARCHAR(20) NOT NULL  -- added V9; filters a child's lesson list to their own grade
  display_order INTEGER NOT NULL
  title VARCHAR(200) NOT NULL
  description VARCHAR(500) NOT NULL

exercises
  id UUID PK
  lesson_code VARCHAR(100) NOT NULL REFERENCES lessons(code)
  skill_code VARCHAR(20) NOT NULL REFERENCES skills
  display_order INTEGER NOT NULL
  prompt VARCHAR(500) NOT NULL
  answer_index INTEGER NOT NULL        -- never serialized into any API response, see ARCHITECTURE.md
  explanation VARCHAR(500) NOT NULL
  hint VARCHAR(500)
  INDEX idx_exercises_lesson_code (lesson_code)

exercise_choices                       -- @ElementCollection + @OrderColumn, not JSONB
  exercise_id UUID NOT NULL REFERENCES exercises ON DELETE CASCADE
  choice_index INTEGER NOT NULL
  choice_text VARCHAR(200) NOT NULL
  PK (exercise_id, choice_index)

-- lesson_progress.lesson_code gained a real FK in V5, once lessons became DB rows (it had none
-- before — see "Why the lesson_code FK was added late" below)
lesson_progress
  id UUID PK
  child_id UUID NOT NULL REFERENCES child_profiles ON DELETE CASCADE
  lesson_code VARCHAR(100) NOT NULL REFERENCES lessons(code)   -- FK added in V5
  score INTEGER NOT NULL CHECK (0-100)        -- derived server-side, never client-submitted (V5+)
  completed BOOLEAN NOT NULL DEFAULT FALSE    -- derived server-side (V5+)
  updated_at TIMESTAMPTZ NOT NULL
  UNIQUE (child_id, lesson_code)
  INDEX idx_lesson_progress_child_id (child_id)

-- Progress tracking (V6)
exercise_attempts
  id UUID PK
  child_id UUID NOT NULL REFERENCES child_profiles ON DELETE CASCADE
  exercise_id UUID NOT NULL REFERENCES exercises
  submitted_answer_index INTEGER NOT NULL
  correct BOOLEAN NOT NULL
  attempted_at TIMESTAMPTZ NOT NULL
  INDEX idx_exercise_attempts_child_exercise (child_id, exercise_id)

skill_progress
  child_id UUID NOT NULL REFERENCES child_profiles ON DELETE CASCADE
  skill_code VARCHAR(20) NOT NULL REFERENCES skills
  attempts_count INTEGER NOT NULL DEFAULT 0 CHECK (>= 0)
  correct_count INTEGER NOT NULL DEFAULT 0 CHECK (>= 0)
  last_attempt_at TIMESTAMPTZ
  PK (child_id, skill_code)

-- Rewards (V7) — coins became a ledger; child_rewards was renamed and lost its coins column
child_streaks                          -- renamed from child_rewards in V7
  child_id UUID PK REFERENCES child_profiles ON DELETE CASCADE
  current_streak INTEGER NOT NULL DEFAULT 0 CHECK (>= 0)
  longest_streak INTEGER NOT NULL DEFAULT 0 CHECK (>= 0)
  last_activity_date DATE

reward_transactions
  id UUID PK
  child_id UUID NOT NULL REFERENCES child_profiles ON DELETE CASCADE
  delta_coins INTEGER NOT NULL
  reason VARCHAR(200) NOT NULL
  reference_type VARCHAR(50) NOT NULL
  reference_id VARCHAR(100) NOT NULL
  created_at TIMESTAMPTZ NOT NULL
  UNIQUE (reference_type, reference_id)      -- the actual duplicate-award prevention, not just app logic
  INDEX idx_reward_transactions_child_id (child_id)

badges
  code VARCHAR(50) PK
  name VARCHAR(100) NOT NULL
  description VARCHAR(300) NOT NULL

child_badges
  child_id UUID NOT NULL REFERENCES child_profiles ON DELETE CASCADE
  badge_code VARCHAR(50) NOT NULL REFERENCES badges
  awarded_at TIMESTAMPTZ NOT NULL
  PK (child_id, badge_code)
```

## Curriculum scope: PRE_K through GRADE_6, Math and English

V8 originally seeded exactly the five topics the master spec names for the MVP (Counting and
Number Recognition, Addition, Subtraction, Number Comparison, Simple Word Problems) as Grade 1
Math only, with English deliberately left out since the MVP scoped to "Grade 1 mathematics"
specifically. That MVP scope was later explicitly expanded by the user to cover every grade from
Pre-K through Grade 6, in both Math and English — V9 added the `grade_level` column and the
`ENGLISH` subject; V10 through V16 seed one grade each (Grade 2 through Grade 6, plus Pre-K and
Kindergarten), 9 Math + 8 English lessons per grade, 3 exercises per lesson.

**Grade 1 was deliberately left at its original 5 lessons, not re-authored to the 17-lesson depth
of the other grades.** It already existed before this expansion and works correctly; rewriting
working MVP content to match a later depth standard wasn't judged worth the risk of introducing
inconsistency with whatever usage/data already depends on those specific lesson codes. If Grade 1
should be brought up to the same depth as the others, that's a clean follow-up (a new migration
adding more Grade 1 lessons), not a rewrite of the existing five.

Skill codes are grade-specific where the underlying skill's difficulty differs by grade (e.g.
`ADDITION` for Grade 1's addition-within-10 vs. `ADD_100` for Grade 2's addition-within-100), so
`skill_progress` accuracy tracking doesn't blend different difficulty levels into one bucket.

## Why the `lesson_code` FK was added late

Sprint 1 deliberately left `lesson_progress.lesson_code` without a foreign key, because the
catalog lived in code (`LessonCatalog`), not a table — there was nothing to reference. Once
exercises needed individual, stable, server-side-only identities (so a correct answer could be
checked without ever handing it to the client), lessons had to become real rows, and the FK
followed naturally. This is not a reversal of the original reasoning, it's the reasoning reaching
its natural conclusion once the catalog's shape changed for an unrelated reason (server-side
grading), not because five lessons suddenly needed enterprise normalization for its own sake.

## Mastery algorithm — still deliberately simple

`SkillProgress.masteryRatio()` is `correctCount / attemptsCount` — a plain recent-accuracy ratio,
nothing more sophisticated. The parent dashboard does not surface per-skill mastery yet (it still
reports per-*subject* strongest/weakest, computed from `lesson_progress`, unchanged from before);
exposing skill-level mastery to parents is a reasonable next step, but should keep this same
plain-ratio honesty — do not let a UI label imply it measures a child's overall ability from a
handful of attempts.

## Retention and deletion

- **Child profiles**: deleting a `parent_accounts` row cascades through every table above via
  `ON DELETE CASCADE` (`child_profiles`, `lesson_progress`, `child_streaks`, `reward_transactions`,
  `child_badges`, `exercise_attempts`, `skill_progress`, `child_learning_preferences`). There is
  still no API endpoint for a parent to delete their own account or a child profile — only the
  cascade behavior exists at the schema level; a delete-account endpoint remains a Phase 5 item.
- **Refresh tokens**: revoked/expired rows are kept as an audit trail, not deleted. No scheduled
  cleanup job exists — unbounded growth over a long-running deployment, unchanged limitation.
- **Reward transactions**: never deleted or mutated once written — the ledger is append-only by
  design, which is what makes it auditable.
- **Homework images**: still not applicable — homework help is text-only (no OCR, no upload, no
  S3 adapter). Unchanged from before.
- **Tutor conversations**: still not persisted — each tutor request remains stateless. Unchanged.

**No legal compliance claim is made here.** Parental consent requirements, applicable children's
privacy laws (e.g. COPPA in the US), app-store policies, and any education-data regulations must
be reviewed by qualified counsel before launch; this document describes the technical retention
mechanics only.
