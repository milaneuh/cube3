INSERT INTO tenants
(full_name)
VALUES
($1)
RETURNING id, full_name;
 
