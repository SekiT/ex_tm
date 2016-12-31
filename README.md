# ex_tm

Just proving Elixir is turing complete.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

```elixir
def deps do
  [{:ex_tm, "~> 0.1.0"}]
end
```

## Example

```elixir
machine = %TuringMachine{
  initial_tape: fn _pos -> "_" end,
  position: 0,
  state: 0,
  accept_states: [3],
}

program = [
  {0, "_", "Hello,", :right, 1},
  {1, "_", " "     , :right, 2},
  {2, "_", "world!", :right, 3},
]

result = TuringMachine.run(machine, program)

TuringMachine.slice_tape(result, 0, 2)
# => ["Hello,", " ", "world!"]
```

## Struct `TuringMachine`

- `initial_tape`: Function from integer to any value, which represents the value of the tape of given position.
- `tape_hash`: Once evaluated tape values are stored in this map. Avoid touching this.
- `position`: Integer which indicates the position of the head.
- `state`: The state of the machine, which can be any type of value.
- `accept_states`: A list of accept states. The machine stops when its state becomes one of them.

## Program

A program is a list of 5-tuple commands.

The command below means: "when the state is `0` and the value of the tape at now position is `"a"`, then turn it into `"b"`, and go `:right`, and make the state `1`".

`{0, "a", "b", :right, 1}`

The direction is one of `:right`, `:left`, `:stay`, `1`, `-1`, `0`.

## Program by code

You can also make program from string:

```elixir
program = TuringMachine.Program.from_string("""
# Make 110100100010000...
0, 0, 1, R, 1
1, 0, 1, R, 1
2, 0, 1, R, 3
3, 0, 1, R, 4

4, 0, 0, L, 4
4, 1, 1, L, 5
5, 0, 0, L, 5
5, 1, 0, L, 6

6, 0, 1, R, 7
7, 0, 0, R, 7
7, 1, 1, R, 8
8, 0, 0, R, 8
8, 1, 0, R, 9
9, 0, 1, L, 4

6 , 1, 1, R, 10
10, 0, 0, R, 10
10, 1, 1, R, 11
11, 0, 0, R, 11
11, 1, 0, R, 1
""")

machine = %TuringMachine{
  initial_tape: fn _pos -> "0" end,
  state: "0",
  accept_states: ["A"],
}

# Step 30 times
Enum.reduce(1..30, machine, fn(_, m) ->
  TuringMachine.step(m, program)
end)
|> TuringMachine.slice_tape(0, 6)
# => ["1", "1", "0", "1", "0", "0", "1"]
```

Each line is considered as a command. `0, 0, 1, R, 1` is interpreted into `{"0", "0", "1", :right, "1"}`.

Note that each value for state or tape is treated as a string.

You can specify direction by `R`, `L`, `S`, or `right`, `left`, `stay`, `1`, `-1`, `0`.

Characters after `#` in a line are ignored, so you can put comments.

You can also use `TuringMachine.Program.from_file/1` to read code from file.
