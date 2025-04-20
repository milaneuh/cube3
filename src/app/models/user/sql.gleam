import gleam/dynamic/decode
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `get_by_id` query
/// defined in `./src/app/models/user/sql/get_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.2 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetByIdRow {
  GetByIdRow(
    id: Uuid,
    email_address: String,
    password_hash: String,
    created_at: String,
  )
}

/// Runs the `get_by_id` query
/// defined in `./src/app/models/user/sql/get_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_by_id(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use email_address <- decode.field(1, decode.string)
    use password_hash <- decode.field(2, decode.string)
    use created_at <- decode.field(3, decode.string)
    decode.success(GetByIdRow(id:, email_address:, password_hash:, created_at:))
  }

  "SELECT
id,
email_address,
password_hash,
created_at::text
FROM users
WHERE id = $1

"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_by_email` query
/// defined in `./src/app/models/user/sql/get_by_email.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.2 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetByEmailRow {
  GetByEmailRow(
    id: Uuid,
    email_address: String,
    password_hash: String,
    created_at: String,
  )
}

/// Runs the `get_by_email` query
/// defined in `./src/app/models/user/sql/get_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_by_email(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use email_address <- decode.field(1, decode.string)
    use password_hash <- decode.field(2, decode.string)
    use created_at <- decode.field(3, decode.string)
    decode.success(
      GetByEmailRow(id:, email_address:, password_hash:, created_at:),
    )
  }

  "SELECT
id,
email_address,
password_hash,
created_at::text
FROM users
WHERE email_address = $1
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create` query
/// defined in `./src/app/models/user/sql/create.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.2 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateRow {
  CreateRow(
    id: Uuid,
    email_address: String,
    password_hash: String,
    created_at: String,
  )
}

/// Runs the `create` query
/// defined in `./src/app/models/user/sql/create.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create(db, arg_1, arg_2) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use email_address <- decode.field(1, decode.string)
    use password_hash <- decode.field(2, decode.string)
    use created_at <- decode.field(3, decode.string)
    decode.success(CreateRow(id:, email_address:, password_hash:, created_at:))
  }

  "INSERT INTO users
(email_address, password_hash)
VALUES
($1, $2)
RETURNING
id,
email_address,
password_hash,
created_at::text;

"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_by_ids` query
/// defined in `./src/app/models/user/sql/get_by_ids.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.2 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetByIdsRow {
  GetByIdsRow(
    id: Uuid,
    email_address: String,
    password_hash: String,
    created_at: String,
  )
}

/// Runs the `get_by_ids` query
/// defined in `./src/app/models/user/sql/get_by_ids.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_by_ids(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use email_address <- decode.field(1, decode.string)
    use password_hash <- decode.field(2, decode.string)
    use created_at <- decode.field(3, decode.string)
    decode.success(GetByIdsRow(id:, email_address:, password_hash:, created_at:),
    )
  }

  "SELECT
    id,
    email_address,
    password_hash,
    created_at::text
FROM
    users
WHERE
    id = ANY($1);
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
