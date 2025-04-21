SELECT
    id,
    user_id,
    created_at::text,
    expires_at::text
FROM user_sessions
WHERE session_hash = $1
