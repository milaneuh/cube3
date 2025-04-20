import gleam/dynamic/decode
import pog
import youid/uuid.{type Uuid}

/// Runs the `delete_pending_roles_by_email` query
/// defined in `./src/app/models/pending_user_tenant_role/sql/delete_pending_roles_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_pending_roles_by_email(db, arg_1) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM pending_user_tenant_roles WHERE email_address = $1;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_pending_roles_by_email_and_tenant` query
/// defined in `./src/app/models/pending_user_tenant_role/sql/delete_pending_roles_by_email_and_tenant.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_pending_roles_by_email_and_tenant(db, arg_1, arg_2) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM pending_user_tenant_roles
WHERE email_address = $1
AND tenant_id = $2;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_pending_role_by_email` query
/// defined in `./src/app/models/pending_user_tenant_role/sql/get_pending_role_by_email.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.2 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPendingRoleByEmailRow {
  GetPendingRoleByEmailRow(tenant_id: Uuid, role_desc: String)
}

/// Runs the `get_pending_role_by_email` query
/// defined in `./src/app/models/pending_user_tenant_role/sql/get_pending_role_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_pending_role_by_email(db, arg_1) {
  let decoder = {
    use tenant_id <- decode.field(0, uuid_decoder())
    use role_desc <- decode.field(1, decode.string)
    decode.success(GetPendingRoleByEmailRow(tenant_id:, role_desc:))
  }

  "SELECT tenant_id, role_desc
FROM pending_user_tenant_roles
WHERE email_address = $1;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `create` query
/// defined in `./src/app/models/pending_user_tenant_role/sql/create.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create(db, arg_1, arg_2, arg_3) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "INSERT INTO pending_user_tenant_roles
(email_address, tenant_id, role_desc)
VALUES
($1, $2, $3)
ON CONFLICT (email_address, tenant_id)
DO UPDATE SET role_desc = $3;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.parameter(pog.text(arg_3))
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
