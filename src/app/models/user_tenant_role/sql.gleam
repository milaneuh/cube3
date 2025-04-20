import gleam/dynamic/decode
import pog
import youid/uuid.{type Uuid}

/// Runs the `remove_tenant_user_role` query
/// defined in `./src/app/models/user_tenant_role/sql/remove_tenant_user_role.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn remove_tenant_user_role(db, arg_1, arg_2) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM tenant_user_roles
WHERE user_id = $1
AND tenant_id = $2;
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_user_tenant_roles` query
/// defined in `./src/app/models/user_tenant_role/sql/get_user_tenant_roles.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.2 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserTenantRolesRow {
  GetUserTenantRolesRow(tenant_id: Uuid, full_name: String, role_desc: String)
}

/// Runs the `get_user_tenant_roles` query
/// defined in `./src/app/models/user_tenant_role/sql/get_user_tenant_roles.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_tenant_roles(db, arg_1) {
  let decoder = {
    use tenant_id <- decode.field(0, uuid_decoder())
    use full_name <- decode.field(1, decode.string)
    use role_desc <- decode.field(2, decode.string)
    decode.success(GetUserTenantRolesRow(tenant_id:, full_name:, role_desc:))
  }

  "SELECT
utr.tenant_id,
t.full_name,
utr.role_desc
FROM tenant_user_roles utr
JOIN tenants t
ON utr.tenant_id = t.id
WHERE user_id = $1;
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `set_user_tenant_role` query
/// defined in `./src/app/models/user_tenant_role/sql/set_user_tenant_role.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn set_user_tenant_role(db, arg_1, arg_2, arg_3) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "INSERT INTO tenant_user_roles 
(user_id, tenant_id, role_desc)
VALUES
($1, $2, $3)
ON CONFLICT (user_id, tenant_id)
DO UPDATE SET role_desc = $3;
  
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.parameter(pog.text(arg_3))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_tenant_user` query
/// defined in `./src/app/models/user_tenant_role/sql/get_tenant_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.2 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetTenantUserRow {
  GetTenantUserRow(email_address: String, role_desc: String, is_pending: Bool)
}

/// Runs the `get_tenant_user` query
/// defined in `./src/app/models/user_tenant_role/sql/get_tenant_user.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_tenant_user(db, arg_1) {
  let decoder = {
    use email_address <- decode.field(0, decode.string)
    use role_desc <- decode.field(1, decode.string)
    use is_pending <- decode.field(2, decode.bool)
    decode.success(GetTenantUserRow(email_address:, role_desc:, is_pending:))
  }

  "SELECT
    u.email_address AS email_address,
    utr.role_desc AS role_desc,
    false AS is_pending
FROM
    tenant_user_roles utr
JOIN
    users u ON utr.user_id = u.id
WHERE
    tenant_id = $1

UNION ALL

SELECT
    putr.email_address AS email_address,
    putr.role_desc AS role_desc,
    true AS is_pending
FROM
    pending_user_tenant_roles putr
WHERE
    tenant_id = $1;
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Encoding/decoding utils -------------------------------------------------

/// A decoder to decode `Uuid`s coming from a Postgres query.
///
fn uuid_decoder() {
  use bit_array <- decode.then(decode.bit_array)
  case uuid.from_bit_array(bit_array) {
    Ok(uuid) -> decode.success(uuid)
    Error(_) -> decode.failure(uuid.v7(), "uuid")
  }
}
