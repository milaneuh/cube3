SELECT tenant_id, role_desc
FROM pending_user_tenant_roles
WHERE email_address = $1;
