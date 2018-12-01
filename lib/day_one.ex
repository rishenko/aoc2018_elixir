defmodule Aoc2018.DayOne do
  @moduledoc "Day 1 of Advent of Code."

  @doc "Sum all values of a give list of frequencies, returning the final result."
  @spec calculate_final_frequency(list(integer)) :: integer
  def calculate_final_frequency(freq_list) do
    Enum.reduce(freq_list, 0, &(&1 + &2))
  end

  @doc """
  Given a list of frequencies and a starting frequency of 0, sum each frequency
  with the previously calculated frequency until you find a repeat of a
  calculated frequency. Return the resulting frequency.
  """
  @spec first_repeated_frequency(list(integer)) :: integer
  def first_repeated_frequency(frequencies) do
    locate_repeated_frequency(frequencies, 0, MapSet.new([0]), frequencies)
  end

  defp locate_repeated_frequency([], prev_result, set, orig_list) do
    locate_repeated_frequency(orig_list, prev_result, set, orig_list)
  end

  defp locate_repeated_frequency([freq | rest], prev_result, set, orig_list) do
    result = freq + prev_result

    if MapSet.member?(set, result) do
      result
    else
      locate_repeated_frequency(rest, result, MapSet.put(set, result), orig_list)
    end
  end
end
