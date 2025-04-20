-- migrate:up

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE pending_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email_address VARCHAR(255) UNIQUE NOT NULL,
    invite_token_hash TEXT NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- migrate:down

