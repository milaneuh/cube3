import app/models/pending_user_tenant_role/pending_user_tenant_role
import app/models/pending_users/pending_user
import app/models/tenant/tenant
import app/models/user_tenant_role/user_tenant_role
import app/types/email.{type Email}
import app/web/layout/layout
import app/web/routes/register
import app/web/web
import formal/form.{type Form}
import gleam/http.{Get, Post}
import gleam/option.{type Option, None}
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
    Get -> register_tenant_form(req_ctx)
    Post -> submit_register_customer_form(req, app_ctx, req_ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

fn register_tenant_form(req_ctx: web.RequestContext) -> Response {
  // Create a new empty Form to render the HTML form with.
  // If the form is for updating something that already exists you may want to
  // use `form.initial_values` to pre-fill some fields.
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
          element.text("Incrire une nouvelle entreprise"),
        ]),
        html.div([attribute.class("border rounded drop-shadow-sm p-4")], [
          html.form([attribute.method("post")], [
            layout.email_input(form, "email", False),
            layout.tenant_name_input(form, "tenant_name"),
            layout.form_error(error),
            html.div([attribute.class("my-4 flex justify-center")], [
              //   html.input([attribute.type_("submit"), attribute.value("Submit")]),
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

fn create_tenant_with_user(
  app_ctx: web.ApplicationContext,
  submission: TenantRegistrationSubmission,
) {
  let assert Ok(tenant) = tenant.create(app_ctx.db, submission.tenant_name)
  let assert Ok(reg_token) = pending_user.create(app_ctx.db, submission.email)
  let assert Ok(_) =
    pending_user_tenant_role.create_pending_user_tenant_role(
      app_ctx.db,
      submission.email,
      tenant.id,
      user_tenant_role.TenantOwner,
    )

  reg_token
  |> register.create_invite_email(submission.email, _)
  |> app_ctx.send_email()

  Ok(Nil)
}

pub type TenantRegistrationSubmission {
  TenantRegistrationSubmission(email: Email, tenant_name: String)
}

fn submit_register_customer_form(
  req: Request,
  app_ctx: web.ApplicationContext,
  req_ctx: web.RequestContext,
) -> Response {
  use formdata <- wisp.require_form(req)

  let result =
    form.decoding({
      use tenant_name <- form.parameter
      use email <- form.parameter
      TenantRegistrationSubmission(email: email, tenant_name: tenant_name)
    })
    |> form.with_values(formdata.values)
    |> form.field(
      "tenant_name",
      form.string |> form.and(form.must_not_be_empty),
    )
    |> form.field("email", form.string |> form.and(email.parse))
    |> form.finish

  case result {
    Ok(submission) -> {
      case create_tenant_with_user(app_ctx, submission) {
        Error(_) -> wisp.internal_server_error()
        Ok(Nil) -> {
          layout.default("Register Customer", req_ctx, [
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
                    html.h1([attribute.class("text-xl font-bold mb-2 pl-1")], [
                      element.text("S'inscrire"),
                    ]),
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
    Error(form) -> {
      layout.default("Register Customer", req_ctx, [
        render_register_form(form, None),
      ])
      |> wisp.html_response(422)
    }
  }
}
