defmodule TuringMachine.ProgramTest do
  use ExUnit.Case
  alias TuringMachine.Program

  test "direction_to_diff/1" do
    assert Program.direction_to_diff(:right) == 1
    assert Program.direction_to_diff(:left ) == -1
    assert Program.direction_to_diff(:stay ) == 0
    assert Program.direction_to_diff(1     ) == 1
    assert Program.direction_to_diff(-1    ) == -1
    assert Program.direction_to_diff(0     ) == 0
  end
end
