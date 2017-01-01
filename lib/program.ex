defmodule TuringMachine.Program do
  @moduledoc """
  Programs for a turing machine.

  You can define programs directly constructing list of 5-tuples,
  or generating from codes by `from_string/1` or `from_file/1`.
  """

  @type direction :: :right | :left | :stay | 1 | -1 | 0
  @type t :: [
    {
      TuringMachine.state,
      TuringMachine.value,
      TuringMachine.value,
      direction,
      TuringMachine.state
    }
  ]

  @spec direction_to_diff(direction) :: 1 | -1 | 0
  def direction_to_diff(direction) do
    case direction do
      :right -> 1
      :left  -> -1
      :stay  -> 0
      diff when is_integer(diff) -> diff
    end
  end
end
