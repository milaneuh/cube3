INSERT INTO user_sessions
(session_hash, user_id,  expires_at)
VALUES
($1, $2, $3);
 
