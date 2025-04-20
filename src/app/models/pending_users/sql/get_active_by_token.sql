SELECT
email_address,
invited_at::text,
expires_at::text
FROM pending_users
WHERE invite_token_hash = $1
AND expires_at > now()

