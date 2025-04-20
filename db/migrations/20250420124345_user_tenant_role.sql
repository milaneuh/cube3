-- migrate:up

CREATE TABLE user_tenant_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID, role_desc VARCHAR(255) NOT NULL); 

-- migrate:down
