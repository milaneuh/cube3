DELETE FROM pending_users
WHERE email_address = $1;
