use Mix.Config

config :scribble, Scribble.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: System.get_env("HOSTNAME"), port: 80],
  cache_static_manifest: "priv/static/manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Do not print debug messages in production
config :logger, level: :info
