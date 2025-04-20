DELETE FROM tenant_user_roles
WHERE user_id = $1
AND tenant_id = $2;
