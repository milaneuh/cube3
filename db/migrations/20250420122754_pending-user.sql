-- migrate:up

CREATE TABLE pending_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email_address VARCHAR(255) UNIQUE NOT NULL,
    invite_token_hash TEXT NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX UX_pending_user_token_hash
ON pending_users (invite_token_hash);

CREATE UNIQUE INDEX UX_pending_user_email
ON pending_users (email_address);

-- migrate:down
DROP TABLE pending_users;
