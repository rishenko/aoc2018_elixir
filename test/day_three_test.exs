defmodule Aoc2018.DayThreeTest do
  use ExUnit.Case
  alias Aoc2018.DayThree

  setup do
    contents = File.read!("priv/day_three_input.txt")
    {:ok, %{input: str_to_line_list(contents)}}
  end

  test "rectangles that overlap two or more other rectangles", %{input: input} do
    rect_list = input |> str_to_line_list() |> DayThree.line_list_to_rectangles()
    DayThree.find_overlapping_rectangles(rect_list, 2)
  end

  def str_to_line_list(str) do
    str
    |> String.trim()
    |> String.split("\n")
  end
end
