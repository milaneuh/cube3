-- migrate:up

CREATE TABLE pending_user_tenant_roles (
    email_address VARCHAR(255) NOT NULL,
    tenant_id UUID NOT NULL,
    role_desc  VARCHAR(255) NOT NULL,
    PRIMARY KEY (email_address, tenant_id)
);

-- migrate:down

