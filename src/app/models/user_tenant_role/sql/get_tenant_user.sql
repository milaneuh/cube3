SELECT
    u.email_address AS email_address,
    utr.role_desc AS role_desc,
    false AS is_pending
FROM
    tenant_user_roles utr
JOIN
    users u ON utr.user_id = u.id
WHERE
    tenant_id = $1

UNION ALL

SELECT
    putr.email_address AS email_address,
    putr.role_desc AS role_desc,
    true AS is_pending
FROM
    pending_user_tenant_roles putr
WHERE
    tenant_id = $1;
