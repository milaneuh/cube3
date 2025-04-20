import app/types/email
import app/web/router
import app/web/web
import dot_env
import dot_env/env
import gleam/erlang/process
import gleam/option
import mist
import pog
import wisp
import wisp/wisp_mist

pub fn main() {
  // This sets the logger to print INFO level logs, and other sensible defaults
  // for a web application.
  wisp.configure_logger()

  // Setting up a new dotenv instance to fetch env variables 
  dot_env.new()
  |> dot_env.set_path(".env")
  |> dot_env.set_debug(False)
  |> dot_env.load()

  // Fetching the secret key base 
  let assert Ok(secret_key_base) = env.get_string("SECRET")

  let db =
    pog.connect(
      pog.Config(
        ..pog.default_config(),
        host: "localhost",
        password: option.Some("postgres"),
        database: "cube-3-indiv",
        pool_size: 15,
      ),
    )

  let app_ctx =
    web.ApplicationContext(
      db: db,
      static_directory: static_directory(),
      send_email: email.print_email_message,
    )

  let handler = router.handle_request(_, app_ctx)
  // Start the Mist web server.
  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8080)
    |> mist.start_http

  // The web server runs in new Erlang process, so put this one to sleep while
  // it works concurrently.
  process.sleep_forever()
}

fn static_directory() {
  let assert Ok(priv_directory) = wisp.priv_directory("app")
  priv_directory <> "/static"
}
