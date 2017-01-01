defmodule TuringMachine do
  @moduledoc """
  Turing machine simulator.
  """

  alias TuringMachine.Program

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

  @doc """
  Get the value of tape at the given position.
  """
  @spec at(t, integer) :: value
  def at(machine, position) do
    case Map.fetch(machine.tape_hash, position) do
      {:ok, val} -> val
      :error     -> (machine.initial_tape).(position)
    end
  end

  @doc """
  Take values of tape in the given range.

  You can pass `from` greater or less than or equal to `to`.
  If `from` is less than `to`, values are reversed.

  ```
  machine = %TuringMachine{initial_tape: fn n -> n end}

  TuringMachine.slice_tape(machine, 0, 2)
  # => [0, 1, 2]

  TuringMachine.slice_tape(machine, 2, -2)
  # => [2, 1, 0, -1, -2]

  TuringMachine.slice_tape(machine, 42, 42)
  # => [42]
  ```
  """
  @spec slice_tape(t, integer, integer) :: list(value)
  def slice_tape(machine, from, to) do
    Enum.map(from..to, &at(machine, &1))
  end

  @doc """
  Process 1 step for the `machine` with the `program`.

  Raises when no command is found for the state.
  """
  @spec step(t, Program.t) :: t | none
  def step(machine, program) do
    %{state: state, position: position} = machine
    value = at(machine, position)
    case Enum.find(program, &match?({^state, ^value, _, _, _}, &1)) do
      nil ->
        raise "No command matches for: #{inspect({state, value})}"
      {_, _, next_value, next_direction, next_state} ->
        position_diff = case next_direction do
          :right ->  1
          :left  -> -1
          :stay  ->  0
          diff when is_integer(diff) -> diff
        end
        Map.merge(machine, %{
          tape_hash: Map.put(machine.tape_hash, position, next_value),
          position:  position + position_diff,
          state:     next_state
        })
    end
  end

  @doc """
  Run the program until the machine state becomes one of its `accept_states`.

  This may go into infinite loop.
  """
  @spec run(t, Program.t) :: t | none
  def run(machine, program) do
    if machine.state in machine.accept_states do
      machine
    else
      run(step(machine, program), program)
    end
  end
end
