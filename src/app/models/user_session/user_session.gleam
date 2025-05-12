import app/models/user/user.{type UserId}
import app/models/user_session/sql
import birl.{type Time}
import birl/duration
import gleam/bit_array
import gleam/crypto
import gleam/option.{type Option, Some}
import gleam/order
import gleam/result
import pog.{type Connection}
import wisp
import youid/uuid

const default_session_days = 7

pub opaque type SessionKey {
  SessionKey(value: String)
}

pub type SessionQueryRecord {
  SessionQueryRecord(
    id: uuid.Uuid,
    user_id: UserId,
    created_at: Time,
    expires_at: Time,
  )
}

pub fn key_to_string(session_key: SessionKey) -> String {
  session_key.value
}

pub fn create_with_defaults(
  conn: Connection,
  user_id: UserId,
) -> Result(#(SessionKey, Int), pog.QueryError) {
  let session_key = wisp.random_string(32)
  let session_hash =
    crypto.hash(crypto.Sha256, bit_array.from_string(session_key))

  let now = birl.utc_now() |> birl.to_iso8601()

  let expiration =
    birl.utc_now()
    |> birl.add(duration.days(default_session_days))
    |> birl.to_iso8601()
  use _ <- result.try({
    sql.create_with_default(
      conn,
      session_hash,
      user_id |> user.id_to_uuid(),
      expiration,
      now,
      now,
    )
  })

  let seconds_until_expiration = default_session_days * 24 * 60 * 60 - 1

  Ok(#(SessionKey(session_key), seconds_until_expiration))
}

pub fn get_by_session_key_string(
  conn: Connection,
  key: String,
) -> Result(Option(SessionQueryRecord), pog.QueryError) {
  let hash = crypto.hash(crypto.Sha256, bit_array.from_string(key))

  use result <- result.try({ sql.get_by_session_key(conn, hash) })
  case result.rows {
    [user_session] -> {
      echo user_session
      let assert Ok(time) = birl.parse(user_session.created_at)
      echo time |> birl.to_date_string()
      let assert Ok(time) = birl.parse(user_session.created_at)
      echo time |> birl.to_date_string()
      Ok(
        Some(
          SessionQueryRecord(
            id: user_session.id,
            user_id: user_session.user_id |> user.UserId,
            created_at: {
              let assert Ok(time) = birl.parse(user_session.created_at)
              time
            },
            expires_at: {
              let assert Ok(time) = birl.parse(user_session.expires_at)
              time
            },
          ),
        ),
      )
    }
    _ -> Ok(option.None)
  }
}

pub fn is_expired(session: SessionQueryRecord) -> Bool {
  case birl.compare(birl.utc_now(), session.expires_at) {
    order.Gt -> True
    _ -> False
  }
}
