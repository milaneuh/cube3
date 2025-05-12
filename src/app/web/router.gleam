import app/web/middleware
import app/web/routes/demo
import app/web/routes/login
import app/web/routes/register
import app/web/routes/register_tenant
import app/web/web.{type ApplicationContext}
import gleam/string_tree
import wisp.{type Request, type Response}

/// The HTTP request handler- your application!
pub fn handle_request(req: Request, app_ctx: ApplicationContext) -> Response {
  // Apply the middleware stack for this request/response.
  use user <- middleware.derive_user(req, app_ctx.db)
  use user_tenant_roles <- middleware.derive_user_tenant_roles(app_ctx.db, user)
  use selected_tenant_id <- middleware.derive_selected_tenant(req)

  let req_ctx =
    web.RequestContext(
      user: user,
      user_tenant_roles: user_tenant_roles,
      selected_tenant_id: selected_tenant_id,
    )
  use req <- web.middleware(req, app_ctx, req_ctx)
  use req_ctx <- middleware.tenant_auth(req, req_ctx)

  // Pattern matching the route 
  case wisp.path_segments(req) {
    // Homepage "/"
    [] -> {
      "<h1>Hello Unconnected user!</h1>"
      |> string_tree.from_string()
      |> wisp.html_response(200)
    }
    ["demo"] -> demo.demo_handler(req, req_ctx, app_ctx)
    ["login"] -> login.login_handler(req, app_ctx, req_ctx)
    ["tenant", "register"] ->
      register_tenant.register_handler(req, app_ctx, req_ctx)
    ["register"] -> register.register_handler(req, app_ctx, req_ctx)
    ["register", "confirm"] -> register.confirm_handler(req, app_ctx, req_ctx)

    // All the empty responses
    ["internal-server-error"] -> wisp.internal_server_error()
    ["unprocessable-entity"] -> wisp.unprocessable_entity()
    ["method-not-allowed"] -> wisp.method_not_allowed([])
    ["entity-too-large"] -> wisp.entity_too_large()
    ["bad-request"] -> wisp.bad_request()
    _ -> wisp.not_found()
  }
}
