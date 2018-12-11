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
  require Logger
  alias Scribble.BoardState, as: State

  # 24 hours
  @timeout 24 * 3600 * 1000

  def start_link(boardId) do
    GenServer.start_link(__MODULE__, [boardId], name: boardId)
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
    # send state to all connected players
    state = %State{id: id, created: Timex.now()}
    broadcast("state", %{}, state)
    {:ok, state, @timeout}
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

  def handle_call({:new_line, player_id, coord}, _from, state = %State{}) do
    {:reply, :ok, State.new_line(player_id, coord, state), @timeout}
  end

  def handle_call({:add_to_line, player_id, coord}, _from, state = %State{}) do
    {:reply, :ok, State.add_to_line(player_id, coord, state), @timeout}
  end

  def handle_info(:timeout, state) do
    Logger.warn("Stopping board #{state.id} due to inactivity")
    {:stop, :normal, state}
  end

  defp broadcast(msg, payload, state) do
    Scribble.Endpoint.broadcast("boards:" <> Atom.to_string(state.id), msg, payload)
  end
end