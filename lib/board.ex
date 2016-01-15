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
      supervisor(Scribble.Board, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
  
end


defmodule Scribble.Board do
  use GenServer
  use Timex
  require Logger

  @timeout 24 * 3600 * 1000 # 24 hours
  
  defmodule State do
    defstruct id: nil, image: nil, lines: %{}, created: nil, modified: nil
  end
  
  def start_link(boardId) do
    result = GenServer.start_link(__MODULE__, [boardId], name: boardId)
    # send state to all connected players
    Scribble.Endpoint.broadcast("boards:" <> Atom.to_string(boardId), "state", %{})
    result
  end

  def get_state(name) do
    GenServer.call(name, :get_state)
  end

  def get_metadata(name) do
    GenServer.call(name, :get_metadata)
  end

  def set_image(name, image) do
    GenServer.call(name, {:set_image, image})
  end

  def new_line(name, player_id, coord) do
    GenServer.call(name, {:new_line, player_id, coord})
  end

  def add_to_line(name, player_id, coord) do
    GenServer.call(name, {:add_to_line, player_id, coord})
  end

  ###

  def init([id]) do
    {:ok, %State{id: id, created: Date.now}, @timeout}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state.lines, state, @timeout}
  end

  def handle_call(:get_metadata, _from, state) do
    {:reply, %{image: state.image, id: state.id, modified: state.modified}, state, @timeout}
  end

  def handle_call({:set_image, image}, _from, state) do
    {:reply, :ok, %State{state | image: image}, @timeout}
  end

  def handle_call({:new_line, player_id, coord}, _from, state=%State{lines: lines}) do
    # make sure we have a coordinate
    if lines[player_id] == nil do
      lines = Map.put(lines, player_id, [])
    end
    player_lines = [[coord] | lines[player_id]]
    new = %State{state | lines: Map.put(lines, player_id, player_lines)}

    {:reply, :ok, new, @timeout}
  end

  def handle_call({:add_to_line, player_id, coord}, _from, state=%State{lines: lines}) do
    [last | rest] = lines[player_id]
    {:reply, :ok, %State{state | lines: Map.put(lines, player_id, [ [coord | last] | rest]), modified: Date.now}, @timeout}
  end

  def handle_info(:timeout, state) do
    Logger.warn "Stopping board #{state.id} due to inactivity"
    {:stop, :normal, state}
  end
  
end

