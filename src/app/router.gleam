import app/web
import gleam/string_tree
import wisp.{type Request, type Response}

/// The HTTP request handler- your application!
pub fn handle_request(req: Request) -> Response {
  // Apply the middleware stack for this request/response.
  use req <- web.middleware(req)

  // Pattern matching the route 
  case wisp.path_segments(req) {
    [] -> hello_world()
    _ -> wisp.not_found()
  }
}

fn hello_world() {
  let body = string_tree.from_string("<h1>Hello World!</h1>")
  wisp.html_response(body, 200)
}
