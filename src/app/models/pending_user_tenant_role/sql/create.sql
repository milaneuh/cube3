INSERT INTO pending_user_tenant_roles
(email_address, tenant_id, role_desc)
VALUES
($1, $2, $3)
ON CONFLICT (email_address, tenant_id)
DO UPDATE SET role_desc = $3;
