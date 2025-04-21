import gleam/dynamic/decode
import pog
import youid/uuid.{type Uuid}

/// Runs the `create_with_default` query
/// defined in `./src/app/models/user_session/sql/create_with_default.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_with_default(db, arg_1, arg_2, arg_3, arg_4) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "INSERT INTO user_sessions
(session_hash, user_id, created_at, expires_at)
VALUES
($1, $2, $3, $4);
 
"
  |> pog.query
  |> pog.parameter(pog.bytea(arg_1))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.parameter(pog.timestamp(arg_3))
  |> pog.parameter(pog.timestamp(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_by_session_key` query
/// defined in `./src/app/models/user_session/sql/get_by_session_key.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.2 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetBySessionKeyRow {
  GetBySessionKeyRow(
    id: Uuid,
    user_id: Uuid,
    created_at: String,
    expires_at: String,
  )
}

/// Runs the `get_by_session_key` query
/// defined in `./src/app/models/user_session/sql/get_by_session_key.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_by_session_key(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use user_id <- decode.field(1, uuid_decoder())
    use created_at <- decode.field(2, decode.string)
    use expires_at <- decode.field(3, decode.string)
    decode.success(GetBySessionKeyRow(id:, user_id:, created_at:, expires_at:))
  }

  "SELECT
    id,
    user_id,
    created_at::text,
    expires_at::text
FROM user_sessions
WHERE session_hash = $1
"
  |> pog.query
  |> pog.parameter(pog.bytea(arg_1))
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
