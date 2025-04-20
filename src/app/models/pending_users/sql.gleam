import gleam/dynamic/decode
import pog

/// Runs the `remove_invite_by_email` query
/// defined in `./src/app/models/pending_users/sql/remove_invite_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn remove_invite_by_email(db, arg_1) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM pending_users
WHERE email_address = $1;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_active_by_token` query
/// defined in `./src/app/models/pending_users/sql/get_active_by_token.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.2 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetActiveByTokenRow {
  GetActiveByTokenRow(
    email_address: String,
    invited_at: String,
    expires_at: String,
  )
}

/// Runs the `get_active_by_token` query
/// defined in `./src/app/models/pending_users/sql/get_active_by_token.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_active_by_token(db, arg_1) {
  let decoder = {
    use email_address <- decode.field(0, decode.string)
    use invited_at <- decode.field(1, decode.string)
    use expires_at <- decode.field(2, decode.string)
    decode.success(GetActiveByTokenRow(email_address:, invited_at:, expires_at:),
    )
  }

  "SELECT
email_address,
invited_at::text,
expires_at::text
FROM pending_users
WHERE invite_token_hash = $1
AND expires_at > now()

"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `create` query
/// defined in `./src/app/models/pending_users/sql/create.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create(db, arg_1, arg_2, arg_3) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "INSERT INTO pending_users
(email_address, invite_token_hash, expires_at)
VALUES
($1, $2, $3)
ON CONFLICT (email_address)
DO UPDATE SET
invite_token_hash = $2,
expires_at = $3;

"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.timestamp(arg_3))
  |> pog.returning(decoder)
  |> pog.execute(db)
}
