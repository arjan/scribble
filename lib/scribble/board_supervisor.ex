defmodule Scribble.BoardSupervisor do
  # Automatically defines child_spec/1
  use DynamicSupervisor

  alias Scribble.Board

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_board(board_id) do
    spec = {Board, board_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
