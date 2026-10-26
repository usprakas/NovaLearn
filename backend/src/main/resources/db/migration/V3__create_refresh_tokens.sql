CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY,
    parent_id UUID NOT NULL REFERENCES parent_accounts(id) ON DELETE CASCADE,
    token_hash VARCHAR(64) NOT NULL UNIQUE,
    issued_at TIMESTAMP WITH TIME ZONE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_refresh_tokens_parent_id ON refresh_tokens(parent_id);
