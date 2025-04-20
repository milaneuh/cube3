import app/models/pending_user_tenant_role/pending_user_tenant_role
import app/models/pending_users/sql
import app/models/user/user
import app/models/user_tenant_role/user_tenant_role
import app/types/email.{type Email}
import app/types/password
import birl.{type Time}
import birl/duration
import gleam/bit_array
import gleam/bool
import gleam/crypto
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import pog
import wisp

const default_invite_duration_minutes = 15

pub type PendingUser {
  PendingUser(email_address: Email, invited_at: Time, expires_at: Time)
}

pub type PendingUserToken {
  PendingUserToken(value: String)
}

pub fn create(
  db: pog.Connection,
  email: Email,
) -> Result(PendingUserToken, pog.QueryError) {
  let invite_token = wisp.random_string(32)
  let token_hash =
    crypto.hash(crypto.Sha256, invite_token |> bit_array.from_string())
    |> bit_array.to_string
    |> result.unwrap("")

  let now = birl.utc_now()

  let #(#(year, month, day), #(hours, minutes, seconds)) =
    now
    |> birl.add(duration.minutes(default_invite_duration_minutes))
    |> birl.to_erlang_universal_datetime

  let expiration =
    pog.Timestamp(
      date: pog.Date(year, month, day),
      time: pog.Time(hours, minutes, seconds, 0),
    )

  use _ <- result.try(sql.create(
    db,
    email |> email.to_string(),
    token_hash,
    expiration,
  ))

  Ok(PendingUserToken(invite_token))
}

pub fn remove_invite_by_email(
  db: pog.Connection,
  email: String,
) -> Result(Nil, pog.QueryError) {
  use _ <- result.try({ sql.remove_invite_by_email(db, email) })
  Ok(Nil)
}

pub fn get_active_invite_by_token(
  db: pog.Connection,
  invite_token: String,
) -> Result(Option(PendingUser), pog.QueryError) {
  let hash = crypto.hash(crypto.Sha256, bit_array.from_string(invite_token))

  use result <- result.try({
    sql.get_active_by_token(
      db,
      hash |> bit_array.to_string() |> result.unwrap(""),
    )
  })

  case result.rows {
    [pending_user] ->
      Ok(
        Some({
          let assert Ok(email) = email.parse(pending_user.email_address)
          let assert Ok(expires_at) = birl.parse(pending_user.expires_at)
          let assert Ok(invited_at) = birl.parse(pending_user.invited_at)
          PendingUser(email, invited_at, expires_at)
        }),
      )
    _ -> Ok(None)
  }
}

pub fn try_redeem_invite(
  db: pog.Connection,
  invite_token: String,
  password: password.Password,
) -> Result(Option(user.User), pog.TransactionError) {
  use conn <- pog.transaction(db)

  let assert Ok(pending) = get_active_invite_by_token(conn, invite_token)

  use <- bool.guard(option.is_none(pending), Ok(None))
  let assert Some(pending) = pending

  let assert Ok(user) =
    user.create(conn, pending.email_address |> email.to_string, password)
  let assert Ok(Nil) =
    remove_invite_by_email(conn, pending.email_address |> email.to_string)

  let assert Ok(pending_roles) =
    pending_user_tenant_role.get_pending_roles_by_email(
      conn,
      user.email_address |> email.to_string,
    )
  case list.is_empty(pending_roles) {
    True -> Nil
    False -> {
      // TODO optimize
      list.each(pending_roles, fn(role) {
        let assert Ok(Nil) =
          user_tenant_role.set_user_tenant_role(
            db,
            user.id,
            role.tenant_id,
            role.role,
          )
      })

      let assert Ok(Nil) =
        pending_user_tenant_role.delete_pending_roles_by_email(
          db,
          user.email_address |> email.to_string,
        )

      Nil
    }
  }

  Ok(Some(user))
}
