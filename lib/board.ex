defmodule Scribble.BoardSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_board(boardId) do
    Supervisor.start_child(__MODULE__, [boardId])
  end
  
  def init(_) do
    children = [
      supervisor(Scribble.Board, [], restart: :permanent)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
  
end


defmodule Scribble.Board do
  def start_link(boardId) do
    Agent.start_link(fn -> %{} end, name: boardId)
  end

  def get_state(name) do
    Agent.get(name, &(&1))
  end

  def new_line(name, player_id, coord) do
    Agent.update(name,
                 fn(state) ->
                   # make sure we have a coordinate
                   if state[player_id] == nil do
                     state = Map.put(state, player_id, [])
                   end
                   lines = [[coord] | state[player_id]]
                   Map.put(state, player_id, lines)
                 end)
  end

  def add_to_line(name, player_id, coord) do
    Agent.update(name,
                 fn(state) ->
                   [last | rest] = state[player_id]
                   Map.put(state, player_id, [ [coord | last] | rest])
                 end)
  end

end

