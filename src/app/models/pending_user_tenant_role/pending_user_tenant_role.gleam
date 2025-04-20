import app/models/pending_user_tenant_role/sql
import app/models/tenant/tenant
import gleam/list

import app/models/user_tenant_role/user_tenant_role.{type UserTenantRole}
import app/types/email.{type Email}
import gleam/result
import pog

pub type PendingUserTenantRole {
  PendingUserTenantRole(
    email_address: Email,
    tenant_id: tenant.TenantId,
    role: user_tenant_role.UserTenantRole,
  )
}

pub fn create_pending_user_tenant_role(
  db: pog.Connection,
  email: Email,
  tenant_id: tenant.TenantId,
  role: UserTenantRole,
) -> Result(Nil, pog.QueryError) {
  use _ <- result.try(sql.create(
    db,
    email |> email.to_string,
    tenant_id |> tenant.id_to_uuid,
    user_tenant_role.role_to_string(role),
  ))

  Ok(Nil)
}

pub fn delete_pending_roles_by_email_and_tenant(
  db: pog.Connection,
  email: Email,
  tenant_id: tenant.TenantId,
) -> Result(Nil, pog.QueryError) {
  use _ <- result.try(sql.delete_pending_roles_by_email_and_tenant(
    db,
    email |> email.to_string,
    tenant_id |> tenant.id_to_uuid,
  ))

  Ok(Nil)
}

pub fn delete_pending_roles_by_email(
  db: pog.Connection,
  email: String,
) -> Result(Nil, pog.QueryError) {
  use _ <- result.try(sql.delete_pending_roles_by_email(db, email))

  Ok(Nil)
}

pub type PendingTenantRole {
  PendingTenantRole(tenant_id: tenant.TenantId, role: UserTenantRole)
}

pub fn get_pending_roles_by_email(
  db: pog.Connection,
  email: String,
) -> Result(List(PendingTenantRole), pog.QueryError) {
  sql.get_pending_role_by_email(db, email)
  |> result.map(fn(x) { x.rows })
  |> result.map(fn(x) {
    x
    |> list.map(fn(data) {
      PendingTenantRole(tenant_id: tenant.tenant_id(data.tenant_id), role: {
        let assert Ok(role) = user_tenant_role.role_from_string(data.role_desc)
        role
      })
    })
  })
}
