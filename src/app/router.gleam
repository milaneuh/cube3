import app/routes/register
import app/web.{type ApplicationContext}
import gleam/string_tree
import wisp.{type Request, type Response}

/// The HTTP request handler- your application!
pub fn handle_request(req: Request, app_ctx: ApplicationContext) -> Response {
  // Apply the middleware stack for this request/response.
  use req <- web.middleware(req, app_ctx)

  // Pattern matching the route 
  case wisp.path_segments(req) {
    // Homepage "/"
    [] -> {
      "<h1>Hello World!</h1>"
      |> string_tree.from_string()
      |> wisp.html_response(200)
    }

    ["register"] -> register.register_handler(req)

    // All the empty responses
    ["internal-server-error"] -> wisp.internal_server_error()
    ["unprocessable-entity"] -> wisp.unprocessable_entity()
    ["method-not-allowed"] -> wisp.method_not_allowed([])
    ["entity-too-large"] -> wisp.entity_too_large()
    ["bad-request"] -> wisp.bad_request()
    _ -> wisp.not_found()
  }
}
