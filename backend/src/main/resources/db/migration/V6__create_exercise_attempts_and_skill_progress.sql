CREATE TABLE exercise_attempts (
    id UUID PRIMARY KEY,
    child_id UUID NOT NULL REFERENCES child_profiles(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES exercises(id),
    submitted_answer_index INTEGER NOT NULL,
    correct BOOLEAN NOT NULL,
    attempted_at TIMESTAMP WITH TIME ZONE NOT NULL
);
CREATE INDEX idx_exercise_attempts_child_exercise ON exercise_attempts(child_id, exercise_id);

CREATE TABLE skill_progress (
    child_id UUID NOT NULL REFERENCES child_profiles(id) ON DELETE CASCADE,
    skill_code VARCHAR(20) NOT NULL REFERENCES skills(code),
    attempts_count INTEGER NOT NULL DEFAULT 0 CHECK (attempts_count >= 0),
    correct_count INTEGER NOT NULL DEFAULT 0 CHECK (correct_count >= 0),
    last_attempt_at TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (child_id, skill_code)
);
