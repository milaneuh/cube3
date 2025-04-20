import gleam/dynamic/decode
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `get_by_id` query
/// defined in `./src/app/models/tenant/sql/get_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.2 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetByIdRow {
  GetByIdRow(id: Uuid, full_name: String)
}

/// Runs the `get_by_id` query
/// defined in `./src/app/models/tenant/sql/get_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_by_id(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use full_name <- decode.field(1, decode.string)
    decode.success(GetByIdRow(id:, full_name:))
  }

  "SELECT
id,
full_name
FROM tenants
 WHERE id = $1;
 
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create` query
/// defined in `./src/app/models/tenant/sql/create.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.2 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateRow {
  CreateRow(id: Uuid, full_name: String)
}

/// Runs the `create` query
/// defined in `./src/app/models/tenant/sql/create.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use full_name <- decode.field(1, decode.string)
    decode.success(CreateRow(id:, full_name:))
  }

  "INSERT INTO tenants
(full_name)
VALUES
($1)
RETURNING id, full_name;
 
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_by_ids` query
/// defined in `./src/app/models/tenant/sql/get_by_ids.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.2 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetByIdsRow {
  GetByIdsRow(id: Uuid, full_name: String)
}

/// Runs the `get_by_ids` query
/// defined in `./src/app/models/tenant/sql/get_by_ids.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_by_ids(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use full_name <- decode.field(1, decode.string)
    decode.success(GetByIdsRow(id:, full_name:))
  }

  "SELECT
id,
full_name
FROM tenants
WHERE id = ANY($1);

"
  |> pog.query
  |> pog.parameter(
    pog.array(fn(value) { pog.text(uuid.to_string(value)) }, arg_1),
  )
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
