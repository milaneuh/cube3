-- migrate:up

CREATE TABLE pending_user_tenant_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email_address VARCHAR(255) NOT NULL,
    tenant_id UUID NOT NULL,
    role  VARCHAR(255) NOT NULL
);

-- migrate:down

