INSERT INTO user_sessions
(session_hash, user_id, created_at, expires_at)
VALUES
($1, $2, $3, $4);
 
