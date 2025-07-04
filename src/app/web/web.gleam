import app/models/tenant/tenant
import app/models/user/user.{type User}
import app/models/user_tenant_role/user_tenant_role.{
  type UserTenantRoleForAccess,
}
import app/types/email
import gleam/bool
import gleam/option.{type Option}
import gleam/string_tree
import pog
import wisp

// Sometimes, we need to share some data across requests to make them easy to access.
// These data are like database connections, user sessions, or even some custom data, 
// like a list of values.
pub type ApplicationContext {
  ApplicationContext(
    static_directory: String,
    db: pog.Connection,
    send_email: fn(email.EmailMessage) -> Result(Nil, String),
  )
}

pub type RequestContext {
  RequestContext(
    user: Option(User),
    user_tenant_roles: Option(List(UserTenantRoleForAccess)),
    selected_tenant_id: Option(tenant.TenantId),
  )
}

pub fn middleware(
  req: wisp.Request,
  app_ctx: ApplicationContext,
  _req_ctx: RequestContext,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  // Permit browsers to simulate methods other than GET and POST using the
  // `_method` query parameter.
  let req = wisp.method_override(req)

  // Serve the static directory 
  use <- wisp.serve_static(
    req,
    under: "/static",
    from: app_ctx.static_directory,
  )

  // Log information about the request and response.
  use <- wisp.log_request(req)

  // Return a default 500 response if the request handler crashes.
  use <- wisp.rescue_crashes

  // Rewrite HEAD requests to GET requests and return an empty body.
  use req <- wisp.handle_head(req)

  use <- default_responses

  // Handle the request!
  handle_request(req)
}

pub fn default_responses(handle_request: fn() -> wisp.Response) -> wisp.Response {
  let response = handle_request()

  use <- bool.guard(when: response.body != wisp.Empty, return: response)

  case response.status {
    404 | 405 ->
      "<h1>Not Found</h1>"
      |> string_tree.from_string()
      |> wisp.html_body(response, _)

    400 | 422 ->
      "<h1>Bad request</h1>"
      |> string_tree.from_string()
      |> wisp.html_body(response, _)

    413 ->
      "<h1>Request entity too large</h1>"
      |> string_tree.from_string()
      |> wisp.html_body(response, _)

    500 ->
      "<h1>Internal server error</h1>"
      |> string_tree.from_string()
      |> wisp.html_body(response, _)

    _ -> response
  }
}
