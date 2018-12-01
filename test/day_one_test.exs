defmodule Aoc2018.DayOneTest do
  use ExUnit.Case
  alias Aoc2018.DayOne

  setup do
    {:ok, %{freq_list: input_str_to_freq_list()}}
  end

  test "puzzle 1", %{freq_list: freq_list} do
    assert 529 == DayOne.calculate_final_frequency(freq_list)
  end

  test "puzzle 2", %{freq_list: freq_list} do
    assert 464 == DayOne.first_repeated_frequency(freq_list)
  end

  def input_str_to_freq_list do
    "priv/day_one_input.txt"
    |> File.read!()
    |> str_to_int_list()
  end

  def str_to_int_list(str) do
    str
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.to_integer(&1))
  end
end
