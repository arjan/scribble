defmodule Scribble.BoardState do
  alias Scribble.BoardState

  defstruct id: nil, image: nil, lines: %{}, created: nil, modified: nil

  def new_line(player_id, coord, state) do
    player_lines = [[coord] | state.lines[player_id] || []]
    %BoardState{state | lines: Map.put(state.lines, player_id, player_lines)}
  end

  def add_to_line(player_id, coord, state) do
    [last | rest] = state.lines[player_id] || []

    %BoardState{
      state
      | lines: Map.put(state.lines, player_id, [[coord | last] | rest]),
        modified: Timex.now()
    }
  end
end
