defmodule Aoc2018.DayTwoTest do
  use ExUnit.Case
  alias Aoc2018.DayTwo

  setup do
    contents = File.read!("priv/day_two_input.txt")
    {:ok, %{input: str_to_line_list(contents)}}
  end

  test "counting chars from lines in file", %{input: input} do
    assert 9139 == DayTwo.lines_checksum(input)
  end

  test "matching boxes by character difference", %{input: input} do
    assert ["uqcidadzwtnhesljvxyobmkfyr", "uqcidadzwtnhwsljvxyobmkfyr"] ==
             DayTwo.locate_closest_matches(input)
  end

  test "common letters", %{input: input} do
    [a, b] = DayTwo.locate_closest_matches(input)
    DayTwo.common_letters(a, b) |> inspect() |> IO.puts()
  end

  def str_to_line_list(str) do
    str
    |> String.trim()
    |> String.split("\n")
  end
end
