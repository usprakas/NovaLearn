ALTER TABLE child_profiles ADD COLUMN grade_level VARCHAR(20) NOT NULL DEFAULT 'GRADE_1';
ALTER TABLE child_profiles ADD COLUMN avatar VARCHAR(20) NOT NULL DEFAULT 'FOX';

CREATE TABLE child_learning_preferences (
    child_id UUID NOT NULL REFERENCES child_profiles(id) ON DELETE CASCADE,
    preference VARCHAR(20) NOT NULL,
    PRIMARY KEY (child_id, preference)
);
