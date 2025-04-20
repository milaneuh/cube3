SELECT
id,
full_name
FROM tenants
WHERE id = ANY($1);

