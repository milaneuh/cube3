import app/layout/layout
import app/web.{type ApplicationContext}
import formal/form.{type Form}
import gleam/http.{Get, Post}
import gleam/option.{type Option, None}
import lustre/attribute
import lustre/element
import lustre/element/html
import wisp.{type Request, type Response}

pub fn register_handler(
  req: Request,
  // app_ctx: ApplicationContext,
  // req_ctx: web.RequestContext,
) {
  case req.method {
    Get -> register_form()
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

fn register_form() -> Response {
  // Create a new empty Form to render the HTML form with.
  // If the form is for updating something that already exists you may want to
  // use `form.initial_values` to pre-fill some fields.
  let form = form.new()

  layout.default("Register", [render_register_form(form, None)])
  |> wisp.html_response(200)
}

fn render_register_form(form: Form, error: Option(String)) {
  html.div([attribute.class("flex justify-center p-4 xs:mt-8 sm:mt-16")], [
    html.div(
      [attribute.class("min-w-96 max-w-96 flex flex-col justify-center")],
      [
        html.h1([attribute.class("text-xl font-bold mb-2 pl-1")], [
          element.text("Register New User"),
        ]),
        html.div([attribute.class("border rounded drop-shadow-sm p-4")], [
          html.form([attribute.method("post")], [
            layout.email_input(form, "email", False),
            layout.form_error(error),
            html.div([attribute.class("my-4 flex justify-center")], [
              //   html.input([attribute.type_("submit"), attribute.value("Submit")]),
              html.button(
                [attribute.class("btn btn-primary"), attribute.type_("submit")],
                [html.text("Register")],
              ),
            ]),
          ]),
        ]),
      ],
    ),
  ])
}
