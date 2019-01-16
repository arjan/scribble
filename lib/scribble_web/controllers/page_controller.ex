defmodule ScribbleWeb.PageController do
  use ScribbleWeb, :controller

  def index(conn, _params) do
    boards =
      for {_, pid, _, [Scribble.Board]} <-
            DynamicSupervisor.which_children(Scribble.BoardSupervisor) do
        Scribble.Board.get_metadata(pid)
      end
      |> Enum.sort(&(&1.modified > &2.modified))

    render(conn, "index.html", boards: boards)
  end

  def new(conn, _params) do
    board_id = Scribble.IdServer.next()
    {:ok, _} = Scribble.BoardSupervisor.start_board(board_id)

    redirect(conn, to: "/board/" <> to_string(board_id))
  end

  def board(conn, params) do
    board = String.to_atom(params["id"])

    case Process.whereis(board) do
      nil ->
        redirect(conn, to: "/")

      _ ->
        render(conn, "board.html", id: params["id"])
    end
  end
end
