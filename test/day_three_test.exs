defmodule Aoc2018.DayThreeTest do
  use ExUnit.Case
  alias Aoc2018.DayThree

  setup do
    contents = File.read!("priv/day_three_input.txt")
    {:ok, %{input: str_to_line_list(contents)}}
  end

  test "example data" do
    contents_2 = ["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"]

    assert 4 =
             contents_2
             |> DayThree.line_list_to_rectangles()
             |> DayThree.count_overlapping_squares()
             |> Enum.filter(fn {_, v} -> v >= 2 end)
             |> length()
  end

  test "problem one", %{input: input} do
    rectangles = DayThree.line_list_to_rectangles(input)

    assert 117_948 =
             rectangles
             |> DayThree.count_overlapping_squares()
             |> Enum.filter(fn {_, v} -> v >= 2 end)
             |> Enum.map(fn {k, _} -> k end)
             |> length()
  end

  test "problem two", %{input: input} do
    rectangles = DayThree.line_list_to_rectangles(input)

    assert 567 =
             DayThree.find_overlapping_rectangles_by_corners(rectangles, 0)
             |> Enum.map(fn {id, _} -> id end)
             |> hd()
  end

  def str_to_line_list(str) do
    str
    |> String.trim()
    |> String.split("\n")
  end
end
