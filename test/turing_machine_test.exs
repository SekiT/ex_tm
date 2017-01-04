defmodule TuringMachineTest do
  use ExUnit.Case

  test "zero_tape/1" do
    positions = [-65536, -2, -1, 0, 1, 2, 65536]
    Enum.each(positions, fn position ->
      assert TuringMachine.zero_tape(position) == "0"
    end)
  end

  test "tape_from_list/1, 2" do
    tape1 = TuringMachine.tape_from_list([0, 1, 2])
    assert tape1.(-1) == "0"
    assert tape1.(0 ) == 0
    assert tape1.(1 ) == 1
    assert tape1.(2 ) == 2
    assert tape1.(3 ) == "0"

    tape2 = TuringMachine.tape_from_list([0, 1, 2], -1)
    assert tape2.(-1) == -1
    assert tape2.(0 ) == 0
    assert tape2.(1 ) == 1
    assert tape2.(2 ) == 2
    assert tape2.(3 ) == -1
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

  test "eval_tape/2" do
    initial_tape = fn n -> n * 2 end
    machine = %TuringMachine{initial_tape: initial_tape}

    assert TuringMachine.eval_tape(machine, [1, 3, 5]) == %TuringMachine{
      initial_tape: initial_tape,
      tape_hash:    %{1 => 2, 3 => 6, 5 => 10},
    }
    assert TuringMachine.eval_tape(machine, -1..2) == %TuringMachine{
      initial_tape: initial_tape,
      tape_hash:    %{-1 => -2, 0 => 0, 1 => 2, 2 => 4},
    }
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
          initial_tape:  tape0,
          state:         0,
          accept_states: [0],
        },
        %TuringMachine{
          initial_tape:  tape0,
          state:         0,
          accept_states: [0],
        }
      },
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

  test "step_times/3" do
    tape0 = fn _ -> 0 end
    machine_before = %TuringMachine{initial_tape: tape0, state: 0}
    program = [
      {0, 0, 1, :right, 1},
      {1, 0, 1, :right, 2},
      {2, 0, 1, :right, "A"},
    ]
    times_after_pairs = [
      {
        0,
        machine_before,
      },
      {
        1,
        %TuringMachine{
          initial_tape: tape0,
          tape_hash:    %{0 => 1},
          state:        1,
          position:     1,
        }
      },
      {
        2,
        %TuringMachine{
          initial_tape: tape0,
          tape_hash:    %{0 => 1, 1 => 1},
          state:        2,
          position:     2,
        }
      },
      {
        3,
        %TuringMachine{
          initial_tape: tape0,
          tape_hash:    %{0 => 1, 1 => 1, 2 => 1},
          state:        "A",
          position:     3,
        }
      },
      {
        4,
        %TuringMachine{
          initial_tape: tape0,
          tape_hash:    %{0 => 1, 1 => 1, 2 => 1},
          state:        "A",
          position:     3,
        }
      },
    ]
    Enum.each(times_after_pairs, fn {times, machine_after} ->
      assert TuringMachine.step_times(machine_before, program, times) == machine_after
    end)
  end

  test "step_times/3"
    <> "doesn't raise when it stops before error" do

    tape0 = fn _ -> 0 end
    machine_before = %TuringMachine{initial_tape: tape0, state: 0}
    program = [
      {0, 0, 1, :right, 1},
      {1, 0, 1, :right, 2},
    ]
    times_after_pairs = [
      {
        0,
        machine_before
      },
      {
        1,
        %TuringMachine{
          initial_tape: tape0,
          tape_hash:    %{0 => 1},
          state:        1,
          position:     1,
        }
      },
      {
        2,
        %TuringMachine{
          initial_tape: tape0,
          tape_hash:    %{0 => 1, 1 => 1},
          state:        2,
          position:     2,
        }
      }
    ]
    Enum.each(times_after_pairs, fn {times, machine_after} ->
      assert TuringMachine.step_times(machine_before, program, times) == machine_after
    end)
  end

  test "step_times/3"
    <> "raise when the program fails" do

    machine = %TuringMachine{state: 0}
    program = [
      {0, "0", "0", :right, 1},
      {1, "0", "0", :right, 2},
    ]
    Enum.each([3, 4], fn times ->
      assert_raise(RuntimeError, fn ->
        TuringMachine.step_times(machine, program, times)
      end)
    end)
  end

  test "run/2" do
    initial_tape = fn n -> n end
    machine = %TuringMachine{
      initial_tape:  initial_tape,
      state:         0,
      accept_states: ["E", "A"],
      position:      0,
    }
    program = [
      {0, 0 , 0, :right, 0},
      {0, 1 , 0, :stay , 0},
      {0, 2 , 1, :stay , 0},
      {0, 3 , 2, :stay , 0},
      {0, 4 , 4, :left , 1},
      {1, 0 , 0, :left , 1},
      {1, -1, 0, :stay , "A"},
    ]
    assert TuringMachine.run(machine, program) == %TuringMachine{
      initial_tape:  initial_tape,
      tape_hash:     %{-1 => 0, 0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 4},
      state:         "A",
      accept_states: ["E", "A"],
      position:      -1,
    }
  end

  test "run/2"
    <> "raise RuntimeError when the program fails" do
    machine = %TuringMachine{
      initial_tape: fn n -> n end,
      state:        0,
    }
    program = [
      {0, 0, 0, :right, 0},
      {0, 1, 0, :stay , 0},
      {0, 2, 1, :stay , 0},
    ]
    assert_raise(RuntimeError, fn ->
      TuringMachine.run(machine, program)
    end)
  end
end
