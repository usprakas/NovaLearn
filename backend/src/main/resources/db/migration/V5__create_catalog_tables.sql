CREATE TABLE subjects (
    code VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE skills (
    code VARCHAR(20) PRIMARY KEY,
    subject_code VARCHAR(20) NOT NULL REFERENCES subjects(code),
    name VARCHAR(100) NOT NULL
);

CREATE TABLE lessons (
    id UUID PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,
    subject_code VARCHAR(20) NOT NULL REFERENCES subjects(code),
    display_order INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    description VARCHAR(500) NOT NULL
);

CREATE TABLE exercises (
    id UUID PRIMARY KEY,
    lesson_code VARCHAR(100) NOT NULL REFERENCES lessons(code),
    skill_code VARCHAR(20) NOT NULL REFERENCES skills(code),
    display_order INTEGER NOT NULL,
    prompt VARCHAR(500) NOT NULL,
    answer_index INTEGER NOT NULL,
    explanation VARCHAR(500) NOT NULL,
    hint VARCHAR(500)
);
CREATE INDEX idx_exercises_lesson_code ON exercises(lesson_code);

CREATE TABLE exercise_choices (
    exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    choice_index INTEGER NOT NULL,
    choice_text VARCHAR(200) NOT NULL,
    PRIMARY KEY (exercise_id, choice_index)
);

-- lesson_progress.lesson_code previously had no referential integrity (see docs/DATABASE_DESIGN.md
-- for why that was a deliberate Sprint 1 decision, now superseded now that lessons are DB rows).
ALTER TABLE lesson_progress ADD CONSTRAINT fk_lesson_progress_lesson_code FOREIGN KEY (lesson_code) REFERENCES lessons(code);
