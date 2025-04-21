-- migrate:up

CREATE TABLE tenant_user_roles (
    user_id UUID NOT NULL
        REFERENCES users (id),
    tenant_id UUID NOT NULL
        REFERENCES tenants (id),
    PRIMARY KEY (user_id, tenant_id),
    role_desc TEXT NOT NULL
);

-- migrate:down
DROP TABLE tenant_user_roles;
