SELECT
id,
email_address,
password_hash,
created_at::text
FROM users
WHERE email_address = $1
