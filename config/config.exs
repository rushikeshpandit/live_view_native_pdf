# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :live_view_native_pdf,
  ecto_repos: [LiveViewNativePdf.Repo],
  generators: [timestamp_type: :utc_datetime]

config :waffle,
  storage: Waffle.Storage.Local,
  # Edit this path to match your storage directory
  storage_dir_prefix: "priv/static",
  storage_dir: "upload_file"

# Configures the endpoint
config :live_view_native_pdf, LiveViewNativePdfWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: LiveViewNativePdfWeb.ErrorHTML, json: LiveViewNativePdfWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: LiveViewNativePdf.PubSub,
  live_view: [signing_salt: "RIsvuux6"]

config :live_view_native_pdf, :upload_dir, Path.expand("../priv/uploads", __DIR__)

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :live_view_native_pdf, LiveViewNativePdf.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  live_view_native_pdf: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  live_view_native_pdf: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix_template, :format_encoders, [
  swiftui: Phoenix.HTML.Engine
]

config :mime, :types, %{
  "text/styles" => ["styles"],
  "text/swiftui" => ["swiftui"]
}

config :live_view_native, plugins: [
  LiveViewNative.SwiftUI
]

config :phoenix, :template_engines, [
  neex: LiveViewNative.Engine
]

config :live_view_native_stylesheet,
  content: [
    swiftui: [
      "lib/**/swiftui/*",
      "lib/**/*swiftui*"
    ]
  ],
  output: "priv/static/assets"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
