import app/models/tenant/sql
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import pog.{type Connection, type QueryError}
import youid/uuid.{type Uuid}

pub opaque type TenantId {
  TenantId(value: Uuid)
}

pub fn tenant_id(value: Uuid) -> TenantId {
  TenantId(value)
}

pub fn id_to_uuid(id: TenantId) -> Uuid {
  id.value
}

pub type Tenant {
  Tenant(id: TenantId, full_name: String)
}

pub fn create(db: Connection, full_name: String) -> Result(Tenant, QueryError) {
  use response <- result.try({ sql.create(db, full_name) })
  let assert Ok(tenant) = list.first(response.rows)
  Ok(Tenant(tenant.id |> tenant_id, tenant.full_name))
}

pub fn get_by_id(
  db: Connection,
  id: TenantId,
) -> Result(Option(Tenant), QueryError) {
  use response <- result.try({ sql.get_by_id(db, id.value) })
  case response.rows {
    [tenant] -> Ok(Some(Tenant(tenant.id |> tenant_id, tenant.full_name)))
    _ -> Ok(None)
  }
}

pub fn get_by_ids(
  db: Connection,
  ids: List(TenantId),
) -> Result(List(Tenant), QueryError) {
  use response <- result.try({
    sql.get_by_ids(db, ids |> list.map(fn(id) { id.value }))
  })
  Ok(
    response.rows
    |> list.map(fn(tenant) { Tenant(tenant.id |> tenant_id, tenant.full_name) }),
  )
}
