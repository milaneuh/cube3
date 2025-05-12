import app/models/user/user
import app/types/email
import app/web/layout/layout
import app/web/middleware
import app/web/web
import gleam/http
import gleam/option
import wisp.{type Request, type Response}

import lustre/element/html.{text}

pub fn demo_handler(
  req: Request,
  req_ctx: web.RequestContext,
  app_ctx: web.ApplicationContext,
) -> Response {
  case req.method {
    http.Get -> hello(req_ctx)
    _ ->
      layout.default("Hello Unconnected user !", req_ctx, [
        html.h1([], [html.text("Hello, !")]),
      ])
  }
  |> wisp.html_response(200)
}

fn hello(req_ctx: web.RequestContext) {
  case req_ctx.user {
    option.None ->
      layout.default("Hello Unconnected user !", req_ctx, [
        html.h1([], [html.text("Hello, Unconnected user !")]),
      ])
    option.Some(user) ->
      layout.default("Hello Unconnected user !", req_ctx, [
        html.h1([], [
          html.text("Hello, " <> user.email_address |> email.to_string <> " !"),
        ]),
      ])
  }
}
