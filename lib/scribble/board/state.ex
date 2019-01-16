defmodule Scribble.Board.State do
  alias Scribble.Board.State

  defstruct id: nil, image: nil, lines: %{}, created: nil, modified: nil

  def new_line(player_id, coord, state) do
    player_lines = [[coord] | state.lines[player_id] || []]
    %State{state | lines: Map.put(state.lines, player_id, player_lines)}
  end

  def add_to_line(player_id, coord, state) do
    [last | rest] = state.lines[player_id] || []

    %State{
      state
      | lines: Map.put(state.lines, player_id, [[coord | last] | rest]),
        modified: DateTime.utc_now()
    }
  end
end
