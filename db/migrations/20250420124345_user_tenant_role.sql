-- migrate:up

CREATE TABLE tenant_user_roles (
    user_id UUID NOT NULL,
    tenant_id UUID NOT NULL,
    role_desc VARCHAR(255) NOT NULL,
    PRIMARY KEY (user_id, tenant_id)
);

-- migrate:down
