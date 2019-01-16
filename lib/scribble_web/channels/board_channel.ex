defmodule ScribbleWeb.BoardChannel do
  use ScribbleWeb, :channel
  require Logger

  def join("boards:" <> id, payload, socket) do
    board = String.to_atom(id)

    case Process.whereis(board) do
      nil ->
        {:error, %{reason: "Board not found"}}

      _ ->
        send(self, :after_join)
        {:ok, assign(socket, :board, board)}
    end
  end

  def handle_in("get_state", _payload, socket) do
    state = Scribble.Board.get_state(socket.assigns.board)
    {:reply, {:ok, state}, socket}
  end

  def handle_in("new", %{"coord" => coord} = payload, socket) do
    Scribble.Board.new_line(socket.assigns.board, socket.assigns.id, coord)
    broadcast(socket, "new", Map.put(payload, :player, socket.assigns.id))
    {:noreply, socket}
  end

  def handle_in("add", %{"coord" => coord} = payload, socket) do
    Scribble.Board.add_to_line(socket.assigns.board, socket.assigns.id, coord)
    broadcast(socket, "add", Map.put(payload, :player, socket.assigns.id))
    {:noreply, socket}
  end

  def handle_in("snapshot", %{"image" => image} = payload, socket) do
    Scribble.Board.set_image(socket.assigns.board, image)
    {:noreply, socket}
  end

  def handle_out(event, payload, socket) do
    push(socket, event, payload)
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "state", Scribble.Board.get_state(socket.assigns.board))
    {:noreply, socket}
  end
end
