INSERT INTO tenant_user_roles 
(user_id, tenant_id, role_desc)
VALUES
($1, $2, $3)
ON CONFLICT (user_id, tenant_id)
DO UPDATE SET role_desc = $3;
  
