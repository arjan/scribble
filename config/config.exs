# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :scribble, Scribble.Endpoint,
  url: [host: "localhost"],
  http: [acceptors: 10],
  root: Path.dirname(__DIR__),
  secret_key_base: "rD7BvwEZM95Bx2GoaeTMkM7w/ZytHwNeOfp0ePe8T9RS076/TzwQhHHHtskXieyt",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Scribble.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :wobserver,
  mode: :plug

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
