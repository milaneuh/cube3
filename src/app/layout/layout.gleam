import formal/form.{type Form}
import gleam/option.{type Option, None, Some}
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element, element}
import lustre/element/html.{text}

pub fn base_html(title: String, children) {
  html.html([attribute("lang", "en")], [
    html.head([], [
      html.meta([attribute.attribute("charset", "UTF-8")]),
      html.meta([
        attribute.attribute("name", "viewport"),
        attribute.attribute("content", "width=device-width, initial-scale=1.0"),
      ]),
      html.title([], title),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/static/css/main.css"),
      ]),
    ]),
    html.body([], children),
  ])
  |> element.to_document_string_builder
}

pub fn default(title: String, content) {
  let auth_element =
    html.div([attribute.class("flex-0")], [
      html.a([attribute.href("/login")], [
        html.button([attribute.class("btn"), attribute.type_("button")], [
          html.text("Login"),
        ]),
      ]),
    ])

  base_html(title, [
    html.div([attribute.class("drawer")], [
      html.input([
        attribute.class("drawer-toggle"),
        attribute.type_("checkbox"),
        attribute.id("page-drawer"),
      ]),
      html.div([attribute.class("drawer-content")], [
        html.header(
          [
            attribute.class(
              "bg-base-100 text-base-content sticky top-0 z-30 flex h-16 w-full justify-center bg-opacity-90 backdrop-blur transition-shadow",
            ),
          ],
          [
            html.nav([attribute.class("navbar w-full")], [
              html.div([attribute.class("flex flex-1 md:gap-1 lg:gap-2")], [
                html.label(
                  [
                    attribute.class("btn btn-neutral drawer-button"),
                    attribute.for("page-drawer"),
                  ],
                  [text("[Product Name]")],
                ),
              ]),
              html.div([attribute.class("flex-0")], [auth_element]),
            ]),
          ],
        ),
        html.main([attribute.class("container")], content),
      ]),
      html.div([attribute.class("drawer-side mt-16")], [
        html.label(
          [
            attribute.class("drawer-overlay"),
            attribute("aria-label", "close sidebar"),
            attribute.for("page-drawer"),
          ],
          [],
        ),
        html.ul(
          [
            attribute.class(
              "menu bg-base-200 text-base-content min-h-full w-80 p-4",
            ),
          ],
          [
            html.li([], [html.a([attribute.href("/demo")], [text("Demo Page")])]),
            html.li([], [html.a([], [text("Something Else")])]),
          ],
        ),
      ]),
    ]),
  ])
}

// Form layouts 
pub fn form_error(error: Option(String)) {
  let error_element = case error {
    None -> element.none()
    Some(message) ->
      html.div(
        [
          attribute.class(
            "alert alert-error py-2 px-4 text-sm rounded text-center",
          ),
          attribute.role("alert"),
        ],
        [html.span([], [text(message)])],
      )
  }

  html.div([attribute.class("min-h-8 mb-2")], [error_element])
}

pub fn field_error(form, name) {
  let error_element = case form.field_state(form, name) {
    Ok(_) -> element.none()
    Error(message) ->
      html.div(
        [
          attribute.class(
            "alert alert-error py-2 px-4 text-sm rounded text-center",
          ),
          attribute.role("alert"),
        ],
        [html.span([], [text(message)])],
      )
  }

  html.div([attribute.class("min-h-8 mb-2")], [error_element])
}

pub fn email_input(form: Form, name: String, disabled: Bool) {
  html.div([attribute.class("mb-2")], [
    html.label(
      [attribute.for("email"), attribute.class("font-bold mb-2 pl-1")],
      [
        element.text("Email"),
        html.div(
          [attribute.class("input input-bordered flex items-center gap-4 mb-2")],
          [
            html.svg(
              [
                attribute.class("h-4 w-4 opacity-70"),
                attribute("fill", "currentColor"),
                attribute("viewBox", "0 0 16 16"),
                attribute("xmlns", "http://www.w3.org/2000/svg"),
              ],
              [
                element(
                  "path",
                  [
                    attribute(
                      "d",
                      "M2.5 3A1.5 1.5 0 0 0 1 4.5v.793c.026.009.051.02.076.032L7.674 8.51c.206.1.446.1.652 0l6.598-3.185A.755.755 0 0 1 15 5.293V4.5A1.5 1.5 0 0 0 13.5 3h-11Z",
                    ),
                  ],
                  [],
                ),
                element(
                  "path",
                  [
                    attribute(
                      "d",
                      "M15 6.954 8.978 9.86a2.25 2.25 0 0 1-1.956 0L1 6.954V11.5A1.5 1.5 0 0 0 2.5 13h11a1.5 1.5 0 0 0 1.5-1.5V6.954Z",
                    ),
                  ],
                  [],
                ),
              ],
            ),
            html.input([
              attribute.placeholder("awesomeperson@example.com"),
              attribute.class("grow"),
              attribute.type_("email"),
              attribute.name(name),
              attribute.required(True),
              attribute.value(form.value(form, name)),
              attribute.autocomplete("off"),
              attribute.disabled(disabled),
            ]),
          ],
        ),
      ],
    ),
    field_error(form, name),
  ])
}
