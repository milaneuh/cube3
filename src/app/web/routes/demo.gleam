import app/types/email
import app/web/layout/layout
import app/web/middleware
import app/web/web
import lustre/attribute
import lustre/element/html
import wisp.{type Request, type Response}

pub fn demo_handler(
  _req: Request,
  _app_ctx: web.ApplicationContext,
  req_ctx: web.RequestContext,
) -> Response {
  use user <- middleware.require_user(req_ctx)

  layout.default("Welcome!", req_ctx, [
    html.div([attribute.class("flex justify-center p-4 xs:mt-8 sm:mt-16")], [
      html.div(
        [
          attribute.class(
            "min-w-96 max-w-96 border rounded drop-shadow-sm p-4 flex flex-col justify-center",
          ),
        ],
        [
          html.span([], [
            html.text("Welcome, " <> email.to_string(user.email_address)),
          ]),
        ],
      ),
    ]),
  ])
  |> wisp.html_response(200)
}
