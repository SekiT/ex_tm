defmodule TuringMachineTest do
  use ExUnit.Case

  test "zero_tape/1" do
    positions = [-65536, -2, -1, 0, 1, 2, 65536]
    Enum.each(positions, fn position ->
      assert TuringMachine.zero_tape(position) == "0"
    end)
  end

  test "at/2" do
    machine_value_pairs = [
      {%TuringMachine{initial_tape: fn n -> n end, tape_hash: %{}      }, 0},
      {%TuringMachine{initial_tape: fn n -> n end, tape_hash: %{0 => 1}}, 1},
      {%TuringMachine{initial_tape: fn n -> n end, tape_hash: %{1 => 3}}, 0},
    ]

    Enum.each(machine_value_pairs, fn {machine, value} ->
      assert TuringMachine.at(machine, 0) == value
    end)
  end

  test "slice_tape/3" do
    machine = %TuringMachine{initial_tape: fn n -> n end}
    assert TuringMachine.slice_tape(machine, 0 , 2 ) == [0, 1, 2]
    assert TuringMachine.slice_tape(machine, 2 , -2) == [2, 1, 0, -1, -2]
    assert TuringMachine.slice_tape(machine, 42, 42) == [42]

    machine_with_hash = %TuringMachine{
      initial_tape: fn n -> n end,
      tape_hash:    %{1 => "a", 3 => "b"},
    }
    assert TuringMachine.slice_tape(machine_with_hash, 1, 3) == ["a", 2, "b"]
    assert TuringMachine.slice_tape(machine_with_hash, 0, 2) == [0, "a", 2]
    assert TuringMachine.slice_tape(machine_with_hash, 0, 4) == [0, "a", 2, "b", 4]
  end

  test "step/2" do
    program = [
      {0  , 0  , 1  , :right, 1  },
      {0  , 1  , 2  , 1     , 1  },
      {0  , "0", "a", :left , 2  },
      {"0", 0  , 3  , :stay , "1"},
      {1  , 0  , 1  , -1    , 2  },
      {2  , 0  , 1  , 0     , 3  },
    ]
    tape0 = fn _ -> 0 end
    before_after_pairs = [
      {
        %TuringMachine{
          initial_tape: tape0,
          state:        0,
          position:     0,
        },
        %TuringMachine{
          initial_tape: tape0,
          tape_hash:    %{0 => 1},
          state:        1,
          position:     1,
        },
      },
      {
        %TuringMachine{
          initial_tape: tape0,
          tape_hash:    %{0 => 1},
          state:        0,
          position:     0,
        },
        %TuringMachine{
          initial_tape: tape0,
          tape_hash:    %{0 => 2},
          state:        1,
          position:     1,
        }
      },
      {
        %TuringMachine{
          state:    0,
          position: 0,
        },
        %TuringMachine{
          tape_hash: %{0 => "a"},
          state:     2,
          position:  -1,
        }
      },
      {
        %TuringMachine{
          initial_tape: tape0,
          state:        "0",
          position:     0,
        },
        %TuringMachine{
          initial_tape: tape0,
          tape_hash:    %{0 => 3},
          state:        "1",
          position:     0,
        }
      },
      {
        %TuringMachine{
          initial_tape: tape0,
          state:        1,
          position:     0,
        },
        %TuringMachine{
          initial_tape: tape0,
          tape_hash:    %{0 => 1},
          state:        2,
          position:     -1,
        }
      },
      {
        %TuringMachine{
          initial_tape: tape0,
          state:        2,
          position:     0,
        },
        %TuringMachine{
          initial_tape: tape0,
          tape_hash:    %{0 => 1},
          state:        3,
          position:     0,
        }
      }
    ]

    Enum.each(before_after_pairs, fn {machine_before, machine_after} ->
      assert TuringMachine.step(machine_before, program) == machine_after
    end)
  end

  test "step/2 "
    <> "raise RuntimeError when no matching command is found" do

    program = [
      {0, 0,  1, :right, 1},
    ]

    machines = [
      %TuringMachine{},
      %TuringMachine{state: 0},
      %TuringMachine{initial_tape: fn _ -> 0 end},
      %TuringMachine{initial_tape: fn _ -> 0 end, tape_hash: %{0 => 1}, state: 0},
      %TuringMachine{initial_tape: fn _ -> 1 end, tape_hash: %{0 => 0}},
    ]

    Enum.each(machines, fn machine ->
      assert_raise(RuntimeError, fn -> TuringMachine.step(machine, program) end)
    end)
  end
end
