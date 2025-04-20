INSERT INTO users
(email_address, password_hash)
VALUES
($1, $2)
RETURNING
id,
email_address,
password_hash,
created_at::text;

