defmodule ScribbleWeb.Presence do
  use Phoenix.Presence,
    otp_app: :scribble,
    pubsub_server: Scribble.PubSub
end
