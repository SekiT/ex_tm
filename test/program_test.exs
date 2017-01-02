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

  test "direction_from_string/1" do
    assert Program.direction_from_string("R"    ) == {:ok, :right}
    assert Program.direction_from_string("L"    ) == {:ok, :left}
    assert Program.direction_from_string("S"    ) == {:ok, :stay}
    assert Program.direction_from_string("right") == {:ok, :right}
    assert Program.direction_from_string("left" ) == {:ok, :left}
    assert Program.direction_from_string("1"    ) == {:ok, 1}
    assert Program.direction_from_string("-1"   ) == {:ok, -1}
    assert Program.direction_from_string("0"    ) == {:ok, 0}
    assert Program.direction_from_string(""     ) == :error
    assert Program.direction_from_string("a"    ) == :error
    assert Program.direction_from_string("r"    ) == :error
    assert Program.direction_from_string("RIGHT") == :error
    assert Program.direction_from_string("2"    ) == :error
    assert Program.direction_from_string("-2"   ) == :error
  end

  test "from_string/1" do
    code_program_pairs = [
      {"", []},
      {"a", []},
      {"1,2", []},
      {"1,2,3", []},
      {"1,2,3,R", []},
      {"1,2,3,R,5,6", []},
      {"#1,2,3,R,5", []},
      {"1,2,3,4,5", []},
      {"1,2,3,r,5", []},
      {"1,2,3,wrong,5", []},
      {"1,2,3,R,5", [{"1", "2", "3", :right, "5"}]},
      {" 1 ,2,3 , L,5 ", [{"1", "2", "3", :left, "5"}]},
      {"foo, b a r, baz, S, 0.1", [{"foo", "b a r", "baz", :stay, "0.1"}]},
      {"1,2,3,right,5\na", [{"1", "2", "3", :right, "5"}]},
      {
        "1,2,3,left,5\n6,7,8,stay,10",
        [
          {"1", "2", "3", :left, "5"},
          {"6", "7", "8", :stay, "10"},
        ]
      },
      {
        "\n1,2,3,1,5\na\n6,7,8,-1,10\n\n11,12,13,0,15\n",
        [
          {"1" , "2" , "3" , 1 , "5" },
          {"6" , "7" , "8" , -1, "10"},
          {"11", "12", "13", 0 , "15"},
        ]
      }
    ]

    Enum.each(code_program_pairs, fn {code, program} ->
      assert Program.from_string(code) == program
    end)
  end

  test "from_file/1" do
    assert Program.from_file("test/test_programs/empty.tm") == []
    assert Program.from_file("test/test_programs/sample.tm") == [
      {"0", "0", "1", :right, "1"},
      {"1", "0", "1", :right, "2"},
      {"2", "0", "1", 1, "3"},
      {"3", "0", "1", :left, "4"},
      {"4", "1", "1", :left, "5"},
      {"5", "1", "1", -1, "6"},
      {"command", "with", "string", :stay, "0.1"},
      {"another", "stay", "command", :stay, "here"},
      {"even", "more", "one", 0, "too"}
    ]

    assert_raise(File.Error, fn -> Program.from_file("nonexisting") end)
  end
end
