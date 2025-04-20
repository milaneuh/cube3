import app/models/tenant/tenant.{type TenantId}
import app/models/user/user.{type UserId}
import app/models/user_tenant_role/sql
import app/types/email
import gleam/list
import gleam/result
import pog

pub type UserTenantRole {
  TenantOwner
  TenantAdmin
  TenantMember
}

pub fn role_to_string(role: UserTenantRole) -> String {
  case role {
    TenantMember -> "member"
    TenantAdmin -> "admin"
    TenantOwner -> "owner"
  }
}

pub fn role_from_string(str: String) -> Result(UserTenantRole, String) {
  case str {
    "member" -> Ok(TenantMember)
    "admin" -> Ok(TenantAdmin)
    "owner" -> Ok(TenantOwner)
    _ -> Error("Invalid role")
  }
}

pub fn set_user_tenant_role(
  db: pog.Connection,
  user_id: UserId,
  tenant_id: TenantId,
  role: UserTenantRole,
) -> Result(Nil, pog.QueryError) {
  use _ <- result.try(sql.set_user_tenant_role(
    db,
    user_id |> user.id_to_uuid,
    tenant_id |> tenant.id_to_uuid,
    role |> role_to_string,
  ))
  Ok(Nil)
}

pub fn remove_tenant_user_role(
  db: pog.Connection,
  tenant_id: TenantId,
  user_id: UserId,
) -> Result(Nil, pog.QueryError) {
  use _ <- result.try(sql.remove_tenant_user_role(
    db,
    user_id |> user.id_to_uuid,
    tenant_id |> tenant.id_to_uuid,
  ))
  Ok(Nil)
}

pub type UserTenantRoleForAccess {
  UserTenantRoleForAccess(
    tenant_id: tenant.TenantId,
    tenant_full_name: String,
    role: UserTenantRole,
  )
}

pub fn get_user_tenant_roles(
  db: pog.Connection,
  user_id: UserId,
) -> Result(List(UserTenantRoleForAccess), pog.QueryError) {
  use result <- result.try(sql.get_user_tenant_roles(
    db,
    user_id |> user.id_to_uuid,
  ))
  Ok(
    result.rows
    |> list.map(fn(row) {
      UserTenantRoleForAccess(
        tenant_id: row.tenant_id |> tenant.tenant_id,
        tenant_full_name: row.full_name,
        role: {
          let assert Ok(role) = row.role_desc |> role_from_string()
          role
        },
      )
    }),
  )
}

pub type TenantUser {
  TenantUser(email_address: email.Email, role: UserTenantRole, is_pending: Bool)
}

pub fn get_tenant_users(
  db: pog.Connection,
  tenant_id: TenantId,
) -> Result(List(TenantUser), pog.QueryError) {
  use result <- result.try(sql.get_tenant_user(
    db,
    tenant_id |> tenant.id_to_uuid,
  ))

  Ok(
    result.rows
    |> list.map(fn(tenant_user) {
      TenantUser(
        is_pending: tenant_user.is_pending,
        role: {
          let assert Ok(role) = tenant_user.role_desc |> role_from_string
          role
        },
        email_address: {
          let assert Ok(email) = email.parse(tenant_user.email_address)
          email
        },
      )
    }),
  )
}
