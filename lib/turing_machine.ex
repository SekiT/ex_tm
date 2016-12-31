defmodule TuringMachine do
  @moduledoc """
  Turing machine simulator.
  """

  @type state :: any
  @type value :: any
  @type t :: %__MODULE__{
    initial_tape:  (integer -> value),
    tape_hash:     %{optional(integer) => value},
    position:      integer,
    state:         state,
    accept_states: list(state),
  }

  @doc """
  Function for the `"0"` filled tape.

  Which is the default `initial_tape` for a `TuringMachine`.

  Note that `"0"` is a string, not an integer.
  It fits to programs `from_string/1` or `from_file/1` deal with strings.
  """
  @spec zero_tape(integer) :: String.t
  def zero_tape(_pos), do: "0"

  defstruct [
    initial_tape:  &__MODULE__.zero_tape/1,
    tape_hash:     %{},
    position:      0,
    state:         "0",
    accept_states: ["A"],
  ]
end
