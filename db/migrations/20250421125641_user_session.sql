-- migrate:up
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_hash BYTEA NOT NULL,
    user_id UUID NOT NULL
        REFERENCES users (id),
    created_at TEXT NOT NULL,
    expires_at TEXT NOT NULL,
    invited_at TEXT NOT NULL
);


-- migrate:down
DROP TABLE user_sessions:
