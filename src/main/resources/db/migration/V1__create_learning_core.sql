CREATE TABLE parent_accounts (
    id UUID PRIMARY KEY, email VARCHAR(320) NOT NULL UNIQUE, password_hash VARCHAR(100) NOT NULL, role VARCHAR(20) NOT NULL,
    CONSTRAINT chk_parent_role CHECK (role = 'PARENT')
);
CREATE TABLE child_profiles (
    id UUID PRIMARY KEY, parent_id UUID NOT NULL REFERENCES parent_accounts(id) ON DELETE CASCADE,
    display_name VARCHAR(60) NOT NULL, birth_date DATE NOT NULL
);
CREATE INDEX idx_child_profiles_parent_id ON child_profiles(parent_id);
CREATE TABLE lesson_progress (
    id UUID PRIMARY KEY, child_id UUID NOT NULL REFERENCES child_profiles(id) ON DELETE CASCADE,
    lesson_code VARCHAR(100) NOT NULL, score INTEGER NOT NULL CHECK (score BETWEEN 0 AND 100), completed BOOLEAN NOT NULL DEFAULT FALSE, updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT uk_lesson_progress_child_lesson UNIQUE (child_id, lesson_code)
);
CREATE INDEX idx_lesson_progress_child_id ON lesson_progress(child_id);
