import app/models/user/user
import app/models/user_session/user_session
import app/types/email
import app/types/password
import app/web/layout/layout
import app/web/web
import formal/form.{type Form}
import gleam/bool
import gleam/erlang/process
import gleam/http.{Get, Post}
import gleam/http/response
import gleam/int
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/result
import lustre/attribute
import lustre/element
import lustre/element/html
import pog
import wisp.{type Request, type Response}

pub fn login_handler(
  req: Request,
  app_ctx: web.ApplicationContext,
  req_ctx: web.RequestContext,
) {
  case req.method {
    Get -> login_form(req_ctx)
    Post -> submit_login_form(req, app_ctx, req_ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

type LoginSubmission {
  LoginSubmission(email: email.Email, password: password.Password)
}

type LoginError {
  InvalidCredentials
  UnknownLoginError
}

fn login(
  conn: pog.Connection,
  email: email.Email,
  password: password.Password,
) -> Result(#(user_session.SessionKey, Int), LoginError) {
  use user <- result.try({
    case user.get_by_email(conn, email) {
      Ok(user) -> Ok(user)
      Error(e) -> {
        echo e
        Error(UnknownLoginError)
      }
    }
  })

  use <- bool.lazy_guard(option.is_none(user), fn() {
    // Always perform a hashing comparison,
    // even when no user found,
    // to prevent timing attacks
    password.verify_random()
    Error(InvalidCredentials)
  })

  let assert Some(user) = user

  use <- bool.guard(
    !password.valid(password, user.password_hash),
    Error(InvalidCredentials),
  )

  //   use <- bool.guard(user.disabled_or_locked(user), Error(InvalidCredentials))

  use session <- result.try({
    case user_session.create_with_defaults(conn, user.id) {
      Ok(session) -> Ok(session)
      Error(e) -> {
        echo e
        Error(UnknownLoginError)
      }
    }
  })

  Ok(session)
}

fn login_form(req_ctx) -> Response {
  let form = form.new()

  layout.default("Login", req_ctx, [render_login_form(form, None)])
  |> wisp.html_response(200)
}

fn submit_login_form(
  req: Request,
  app_ctx: web.ApplicationContext,
  req_ctx: web.RequestContext,
) -> Response {
  use formdata <- wisp.require_form(req)

  let result =
    form.decoding({
      use email <- form.parameter
      use password <- form.parameter
      LoginSubmission(email: email, password: password)
    })
    |> form.with_values(formdata.values)
    |> form.field("email", form.string |> form.and(email.parse))
    |> form.field(
      "password",
      form.string
        |> form.and(password.create),
    )
    |> form.finish
  echo result
  case result {
    // The form was valid! Do something with the data and render a page to the user
    Ok(data) -> {
      case login(app_ctx.db, data.email, data.password) {
        Ok(#(session_key, seconds_until_expiration)) -> {
          let response =
            wisp.redirect("/demo")
            |> wisp.set_cookie(
              req,
              "session",
              user_session.key_to_string(session_key),
              wisp.Signed,
              seconds_until_expiration,
            )

          echo response |> response.get_cookies()
          response
        }
        Error(InvalidCredentials) -> {
          // Timing obfuscation + poor man's rate-limiting
          process.sleep(int.random(201) + 100)
          layout.default("Login", req_ctx, [
            render_login_form(
              form.initial_values([#("email", email.to_string(data.email))]),
              Some("Identifiants invalides."),
            ),
          ])
          |> wisp.html_response(401)
        }
        Error(UnknownLoginError) -> {
          layout.default("Login", req_ctx, [
            render_login_form(
              form.new(),
              Some(
                "Une erreur est survenue lors de la tentative de connexion sur votre compte.",
              ),
            ),
          ])
          |> wisp.html_response(500)
        }
      }
    }

    // The form was invalid. Render the HTML form again with the errors
    Error(form) -> {
      layout.default("Register", req_ctx, [render_login_form(form, None)])
      |> wisp.html_response(422)
    }
  }
}

fn render_login_form(form: Form, error: Option(String)) {
  html.div([attribute.class("flex justify-center p-4 mt-8")], [
    html.div(
      [attribute.class("min-w-96 max-w-96 flex flex-col justify-center")],
      [
        html.h1([attribute.class("text-xl font-bold mb-2 pl-1")], [
          element.text("Connexion d'utilisateur"),
        ]),
        html.div([attribute.class("border rounded drop-shadow-sm p-4")], [
          html.form([attribute.method("post")], [
            layout.email_input(form, "email", False),
            layout.password_input(form, "password"),
            layout.form_error(error),
            html.div([attribute.class("my-2 flex justify-center")], [
              //   html.input([attribute.type_("submit"), attribute.value("Submit")]),
              html.button(
                [attribute.class("btn btn-primary"), attribute.type_("submit")],
                [html.text("Se connecter")],
              ),
            ]),
            html.div([attribute.class("divider")], []),
            html.div(
              [
                attribute.class(
                  "my-4 flex flex-col justify-center items-center",
                ),
              ],
              [
                html.p([attribute.class("mb-2")], [
                  html.text("Besoins d'un compte ?"),
                ]),
                html.a([attribute.href("/register")], [
                  html.button(
                    [attribute.class("btn"), attribute.type_("button")],
                    [html.text("S'inscrire")],
                  ),
                ]),
              ],
            ),
          ]),
        ]),
      ],
    ),
  ])
}
