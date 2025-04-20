import app/models/user/sql
import app/types/email.{type Email}
import app/types/password.{type Password}
import birl.{type Time}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import pog
import youid/uuid.{type Uuid}

pub type UserId {
  UserId(value: Uuid)
}

pub fn id_to_uuid(id: UserId) -> Uuid {
  id.value
}

pub type User {
  User(
    id: UserId,
    email_address: Email,
    password_hash: String,
    created_at: Time,
  )
}

pub fn create(
  db: pog.Connection,
  email: String,
  password: Password,
) -> Result(User, pog.QueryError) {
  let password_hash = password.hash(password)
  use response <- result.try({ sql.create(db, email, password_hash) })

  let assert Ok(user) = list.first(response.rows)
  let assert Ok(created_at) = birl.parse(user.created_at)
  let assert Ok(email) = email.parse(user.email_address)
  Ok(User(
    id: UserId(user.id),
    password_hash: user.password_hash,
    created_at: created_at,
    email_address: email,
  ))
}

pub fn get_by_id(
  db: pog.Connection,
  id: UserId,
) -> Result(Option(User), pog.QueryError) {
  use result <- result.try({ sql.get_by_id(db, id.value) })

  case result.rows {
    [] -> Ok(None)
    [user] ->
      Ok({
        let assert Ok(created_at) = birl.parse(user.created_at)
        let assert Ok(email) = email.parse(user.email_address)
        Some(User(
          id: UserId(user.id),
          password_hash: user.password_hash,
          created_at: created_at,
          email_address: email,
        ))
      })
    _ -> panic as "Unreachable"
  }
}

pub fn get_by_ids(
  db: pog.Connection,
  ids: List(UserId),
) -> Result(List(User), pog.QueryError) {
  use result <- result.try({
    sql.get_by_ids(db, ids |> list.map(fn(x) { x.value }))
  })

  Ok(
    result.rows
    |> list.map(fn(user) {
      let assert Ok(created_at) = birl.parse(user.created_at)
      let assert Ok(email) = email.parse(user.email_address)
      User(
        id: UserId(user.id),
        password_hash: user.password_hash,
        created_at: created_at,
        email_address: email,
      )
    }),
  )
}

pub fn get_by_email(
  db: pog.Connection,
  email: Email,
) -> Result(Option(User), pog.QueryError) {
  use result <- result.try({ sql.get_by_email(db, email |> email.to_string) })
  case result.rows {
    [] -> Ok(None)
    [user] ->
      Ok({
        let assert Ok(created_at) = birl.parse(user.created_at)
        let assert Ok(email) = email.parse(user.email_address)
        Some(User(
          id: UserId(user.id),
          password_hash: user.password_hash,
          created_at: created_at,
          email_address: email,
        ))
      })
    _ -> panic as "Unreachable"
  }
}
