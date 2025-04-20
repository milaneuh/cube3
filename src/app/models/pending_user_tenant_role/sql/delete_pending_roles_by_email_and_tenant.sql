DELETE FROM pending_user_tenant_roles
WHERE email_address = $1
AND tenant_id = $2;
