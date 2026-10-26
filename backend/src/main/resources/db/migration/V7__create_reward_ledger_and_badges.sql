-- Coins become an auditable ledger instead of a mutable accumulator; child_rewards keeps only
-- streak state and is renamed to reflect that (see docs/ADR for the reward-ledger decision).
ALTER TABLE child_rewards RENAME TO child_streaks;
ALTER TABLE child_streaks DROP COLUMN coins;

CREATE TABLE reward_transactions (
    id UUID PRIMARY KEY,
    child_id UUID NOT NULL REFERENCES child_profiles(id) ON DELETE CASCADE,
    delta_coins INTEGER NOT NULL,
    reason VARCHAR(200) NOT NULL,
    reference_type VARCHAR(50) NOT NULL,
    reference_id VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT uk_reward_transactions_reference UNIQUE (reference_type, reference_id)
);
CREATE INDEX idx_reward_transactions_child_id ON reward_transactions(child_id);

CREATE TABLE badges (
    code VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(300) NOT NULL
);

CREATE TABLE child_badges (
    child_id UUID NOT NULL REFERENCES child_profiles(id) ON DELETE CASCADE,
    badge_code VARCHAR(50) NOT NULL REFERENCES badges(code),
    awarded_at TIMESTAMP WITH TIME ZONE NOT NULL,
    PRIMARY KEY (child_id, badge_code)
);

INSERT INTO badges (code, name, description) VALUES
    ('FIRST_STEPS', 'First Steps', 'Completed your very first lesson!'),
    ('FIVE_DAY_STREAK', 'On a Roll', 'Practiced for 5 days in a row!');
