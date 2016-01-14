defmodule Scribble.PageController do
  use Scribble.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def new(conn, _params) do
    board_id = Scribble.IdServer.next
    Scribble.BoardSupervisor.start_board(board_id)
    redirect conn, to: "/board/" <> Atom.to_string(board_id)
  end

  def board(conn, params) do
    board = String.to_atom(params["id"])
    case Process.whereis(board) do
      nil -> redirect conn, to: "/"
      _ -> 
        render conn, "board.html", id: params["id"]
    end
  end

end
