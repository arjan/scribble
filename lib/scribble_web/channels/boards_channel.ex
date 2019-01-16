defmodule ScribbleWeb.BoardsChannel do
  use ScribbleWeb, :channel
  require Logger

  def join("boards", payload, socket) do
    Phoenix.PubSub.subscribe(Scribble.PubSub, "boards")
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_out(event, payload, socket) do
    push(socket, event, payload)
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", ScribbleWeb.Presence.list("boards"))
    {:noreply, socket}
  end
end
