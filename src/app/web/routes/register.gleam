import app/models/pending_users/pending_user
import app/models/user_session/user_session
import app/types/email
import app/types/password
import app/web/layout/layout
import app/web/web
import formal/form.{type Form}
import gleam/bool
import gleam/dict
import gleam/http.{Get, Post}
import gleam/list
import gleam/option.{type Option, None}
import gleam/result
import lustre/attribute
import lustre/element
import lustre/element/html
import wisp.{type Request, type Response}

pub fn register_handler(
  req: Request,
  app_ctx: web.ApplicationContext,
  req_ctx: web.RequestContext,
) {
  case req.method {
    Get -> register_form(req_ctx)
    Post -> submit_register_form(req, app_ctx, req_ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

pub fn confirm_handler(
  req: Request,
  app_ctx: web.ApplicationContext,
  req_ctx: web.RequestContext,
) {
  case req.method {
    Get -> confirmation_form(req, app_ctx, req_ctx)
    Post -> submit_confirmation_form(req, app_ctx, req_ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

fn submit_register_form(
  req: Request,
  app_ctx: web.ApplicationContext,
  req_ctx: web.RequestContext,
) -> Response {
  use formdata <- wisp.require_form(req)

  let result =
    form.decoding({
      use email <- form.parameter
      email
    })
    |> form.with_values(formdata.values)
    |> form.field("email", form.string |> form.and(email.parse))
    |> form.finish

  case result {
    Ok(email) -> {
      case pending_user.create(app_ctx.db, email) {
        Ok(pending_user_token) -> {
          let email_attempt =
            create_invite_email(email, pending_user_token)
            |> app_ctx.send_email()
          case email_attempt {
            Error(e) -> {
              echo e
              layout.default("Register", req_ctx, [
                render_register_form(
                  form.new(),
                  option.Some(
                    "Une erreur est survenue lors de la tentative de création de votre compte.",
                  ),
                ),
              ])
              |> wisp.html_response(500)
            }
            Ok(Nil) -> {
              layout.default("Register", req_ctx, [
                html.div(
                  [attribute.class("flex justify-center p-4 xs:mt-8 sm:mt-16")],
                  [
                    html.div(
                      [
                        attribute.class(
                          "min-w-96 max-w-96 flex flex-col justify-center",
                        ),
                      ],
                      [
                        html.h1(
                          [attribute.class("text-xl font-bold mb-2 pl-1")],
                          [element.text("S'inscrire")],
                        ),
                        html.div(
                          [attribute.class("border rounded drop-shadow-sm p-4")],
                          [
                            html.p([], [
                              html.text(
                                "Un lien d'inscription a été envoyé à votre adresse e-mail.",
                              ),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ])
              |> wisp.html_response(201)
            }
          }
        }
        Error(e) -> {
          echo e
          layout.default("Register", req_ctx, [
            render_register_form(
              form.new(),
              option.Some(
                "Une erreur est survenue lors de la tentative de création de votre compte.",
              ),
            ),
          ])
          |> wisp.html_response(500)
        }
      }
    }

    Error(form) -> {
      layout.default("Register", req_ctx, [render_register_form(form, None)])
      |> wisp.html_response(422)
    }
  }
}

fn register_form(req_ctx: web.RequestContext) -> Response {
  let form = form.new()

  layout.default("Register", req_ctx, [render_register_form(form, None)])
  |> wisp.html_response(200)
}

fn render_register_form(form: Form, error: Option(String)) {
  html.div([attribute.class("flex justify-center p-4 xs:mt-8 sm:mt-16")], [
    html.div(
      [attribute.class("min-w-96 max-w-96 flex flex-col justify-center")],
      [
        html.h1([attribute.class("text-xl font-bold mb-2 pl-1")], [
          element.text("Inscrire un nouvel utilisateur"),
        ]),
        html.div([attribute.class("border rounded drop-shadow-sm p-4")], [
          html.form([attribute.method("post")], [
            layout.email_input(form, "email", False),
            layout.form_error(error),
            html.div([attribute.class("my-4 flex justify-center")], [
              html.button(
                [attribute.class("btn btn-primary"), attribute.type_("submit")],
                [html.text("S'inscrire")],
              ),
            ]),
          ]),
        ]),
      ],
    ),
  ])
}

pub fn create_invite_email(
  address: email.Email,
  token: pending_user.PendingUserToken,
) {
  let link = "http://localhost:8080/register/confirm?token=" <> token.value
  let body =
    html.html([attribute.attribute("lang", "en")], [
      html.head([], [
        html.meta([attribute.attribute("charset", "UTF-8")]),
        html.meta([
          attribute.attribute("name", "viewport"),
          attribute.attribute(
            "content",
            "width=device-width, initial-scale=1.0",
          ),
        ]),
      ]),
      html.body([], [html.a([attribute.href(link)], [html.text(link)])]),
    ])
    |> element.to_string

  email.EmailMessage(
    recipients: [address],
    subject: "Cube 3 Demo - Liens d'enregistrement",
    body: body,
  )
}

fn query_token(req) {
  req |> wisp.get_query() |> list.key_find("token")
}

fn confirmation_form(
  req: Request,
  app_ctx: web.ApplicationContext,
  req_ctx: web.RequestContext,
) -> Response {
  let token = query_token(req)
  use <- bool.guard(
    result.is_error(token),
    invalid_or_expired_confirmation_token(req_ctx),
  )
  let assert Ok(token) = token

  let invite = pending_user.get_active_invite_by_token(app_ctx.db, token)
  use <- bool.guard(result.is_error(invite), wisp.internal_server_error())

  let assert Ok(invite) = invite
  use <- bool.guard(
    option.is_none(invite),
    invalid_or_expired_confirmation_token(req_ctx),
  )

  let assert option.Some(invite) = invite
  let form =
    form.initial_values([
      #("token", token),
      #("email", email.to_string(invite.email_address)),
    ])

  layout.default("Confirm Registration", req_ctx, [
    render_confirmation_form(form, None),
  ])
  |> wisp.html_response(200)
}

fn render_confirmation_form(form: Form, error: Option(String)) {
  html.div([attribute.class("flex justify-center p-4 xs:mt-8 sm:mt-16")], [
    html.div(
      [attribute.class("min-w-96 max-w-96 flex flex-col justify-center")],
      [
        html.h1([attribute.class("text-xl font-bold mb-2 pl-1")], [
          element.text("Inscription d'un nouvel utilisateur"),
        ]),
        html.div([attribute.class("border rounded drop-shadow-sm p-4")], [
          html.form([attribute.method("post")], [
            layout.email_input(form, "email", True),
            layout.password_input(form, "password"),
            html.input([
              attribute.type_("hidden"),
              attribute.name("token"),
              attribute.value(form.value(form, "token")),
            ]),
            layout.form_error(error),
            html.div([attribute.class("my-4 flex justify-center")], [
              html.button(
                [attribute.class("btn btn-primary"), attribute.type_("submit")],
                [html.text("S'inscrire")],
              ),
            ]),
          ]),
        ]),
      ],
    ),
  ])
}

pub type ConfirmationSubmission {
  ConfirmationSubmission(token: String, password: password.Password)
}

fn invalid_or_expired_confirmation_token(app_ctx) {
  layout.default("Invalid Registration Link", app_ctx, [
    html.div([attribute.class("flex justify-center p-4 xs:mt-8 sm:mt-16")], [
      html.div(
        [attribute.class("min-w-96 max-w-96 flex flex-col justify-center")],
        [
          html.h1([attribute.class("text-xl font-bold mb-2 pl-1")], [
            element.text("Lien d'inscription invalide"),
          ]),
          html.div([attribute.class("border rounded drop-shadow-sm p-4")], [
            html.div(
              [
                attribute.class(
                  "alert alert-warning py-2 px-4 text-sm rounded text-center flex flex-col",
                ),
                attribute.role("alert"),
              ],
              [
                html.p([attribute.class("font-bold")], [
                  html.text("Ce lien d'inscription est invalide ou a expiré."),
                ]),
              ],
            ),
          ]),
        ],
      ),
    ]),
  ])
  |> wisp.html_response(404)
}

fn submit_confirmation_form(
  req: Request,
  app_ctx: web.ApplicationContext,
  req_ctx: web.RequestContext,
) -> Response {
  let token = query_token(req)
  use <- bool.guard(
    result.is_error(token),
    invalid_or_expired_confirmation_token(req_ctx),
  )
  let assert Ok(token) = token

  let invite = pending_user.get_active_invite_by_token(app_ctx.db, token)
  use <- bool.lazy_guard(result.is_error(invite), fn() {
    wisp.internal_server_error()
  })

  let assert Ok(invite) = invite
  use <- bool.guard(
    option.is_none(invite),
    invalid_or_expired_confirmation_token(req_ctx),
  )
  let assert option.Some(invite) = invite

  let password_policy = password.PasswordPolicy(min_length: 12, max_length: 50)
  use formdata <- wisp.require_form(req)

  let result =
    form.decoding({
      use token <- form.parameter
      use password <- form.parameter
      ConfirmationSubmission(token: token, password: password)
    })
    |> form.with_values(formdata.values)
    |> form.field("token", form.string |> form.and(form.must_not_be_empty))
    |> form.field(
      "password",
      form.string
        |> form.and(password.create)
        |> form.and(password.policy_compliant(_, password_policy)),
    )
    |> form.finish

  case result {
    Ok(data) -> {
      case
        pending_user.try_redeem_invite(app_ctx.db, data.token, data.password)
      {
        Ok(user) -> {
          echo user
          use <- bool.guard(
            option.is_none(user),
            invalid_or_expired_confirmation_token(req_ctx),
          )
          let assert option.Some(user) = user
          case user_session.create_with_defaults(app_ctx.db, user.id) {
            Ok(#(session_key, seconds_until_expiration)) -> {
              wisp.redirect("/demo")
              |> wisp.set_cookie(
                req,
                "session",
                user_session.key_to_string(session_key),
                wisp.Signed,
                seconds_until_expiration,
              )
            }
            Error(e) -> {
              echo e
              wisp.internal_server_error()
            }
          }
        }

        Error(e) -> {
          echo e
          layout.default("Confirm Registration", req_ctx, [
            render_confirmation_form(
              form.initial_values([
                #("token", token),
                #("email", email.to_string(invite.email_address)),
              ]),
              // form.new(),
              option.Some(
                "Une erreur est survenue lors de la tentative de création de votre compte.",
              ),
            ),
          ])
          |> wisp.html_response(500)
        }
      }
    }

    Error(form) -> {
      echo form
      let form =
        form.Form(
          values: form.values
            |> dict.insert("email", [email.to_string(invite.email_address)])
            |> dict.insert("token", [token]),
          errors: form.errors,
        )
      layout.default("Confirm Registration", req_ctx, [
        render_confirmation_form(form, None),
      ])
      |> wisp.html_response(422)
    }
  }
}
