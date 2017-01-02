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

  @spec direction_from_string(String.t) :: {:ok, direction} | :error
  %{
    "R"     => :right,
    "L"     => :left,
    "S"     => :stay,
    "right" => :right,
    "left"  => :left,
    "stay"  => :stay,
    "1"     => 1,
    "-1"    => -1,
    "0"     => 0,
  }
  |> Enum.each(fn {dir_str, dir} ->
    def direction_from_string(unquote(dir_str)), do: {:ok, unquote(dir)}
  end)
  def direction_from_string(_other), do: :error

  @spec from_string(String.t) :: t
  def from_string(code) do
    code
    |> String.replace(~r/#.*/, "")
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ","))
    |> Enum.filter_map(
      fn list -> length(list) == 5 end,
      fn list -> Enum.map(list, &String.trim/1) end
    )
    |> Enum.filter_map(
      fn [_, _, _, dir_str, _] ->
        match?({:ok, _}, direction_from_string(dir_str))
      end,
      fn [state0, value0, value1, dir_str, state1] ->
        {:ok, dir} = direction_from_string(dir_str)
        {state0, value0, value1, dir, state1}
      end
    )
  end
end
