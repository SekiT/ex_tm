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
end
