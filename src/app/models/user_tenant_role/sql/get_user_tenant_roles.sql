SELECT
utr.tenant_id,
t.full_name,
utr.role_desc
FROM tenant_user_roles utr
JOIN tenants t
ON utr.tenant_id = t.id
WHERE user_id = $1;
