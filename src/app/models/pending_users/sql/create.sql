INSERT INTO pending_users
(email_address, invite_token_hash, expires_at)
VALUES
($1, $2, $3)
ON CONFLICT (email_address)
DO UPDATE SET
invite_token_hash = $2,
expires_at = $3;

