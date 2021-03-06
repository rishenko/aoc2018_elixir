defmodule Aoc2018.DayTwo do
  @moduledoc "Day Two of Advent of Code 2018"

  @starting_count %{2 => 0, 3 => 0}

  def lines_checksum(input) do
    input
    |> lines_logic()
    |> Enum.reduce(1, fn {_, v}, acc -> v * acc end)
  end

  def lines_logic(lines, acc \\ @starting_count) do
    Enum.reduce(lines, acc, &line_logic(&1, &2))
  end

  def line_logic(line, acc \\ %{2 => 0, 3 => 0}) do
    line
    |> codepoint_counts()
    |> Map.values()
    |> Enum.filter(&(&1 == 2 or &1 == 3))
    |> Enum.uniq()
    |> do_line_logic(acc)
  end

  defp do_line_logic([], acc), do: acc

  defp do_line_logic([c | rest], acc) do
    do_line_logic(rest, Map.update(acc, c, 1, fn v -> v + 1 end))
  end

  def codepoint_counts(str) do
    do_count(str, %{})
  end

  for c <- ?a..?z do
    def do_count(<<>>, map), do: map

    def do_count(<<unquote(c), rest::binary>>, map) do
      do_count(rest, Map.update(map, unquote(c), 1, fn v -> v + 1 end))
    end
  end

  def locate_closest_matches(input, type) do
    input
    |> Task.async_stream(&find_closest_line(&1, input, type))
    |> Enum.filter(fn {:ok, {_, matches}} -> length(matches) > 0 end)
    |> Enum.map(fn {:ok, {v, _}} -> v end)
  end

  def find_closest_line(line, all_lines, type) do
    expected_length = String.length(line) - 1

    {line,
     Enum.reduce(all_lines, [], fn
       ^line, acc ->
         acc

       input_line, acc ->
         compare_lines(input_line, line, acc, expected_length, type)
     end)}
  end

  def compare_lines(a, b, acc, expected_length, :myers) do
    String.myers_difference(a, b)
    |> Enum.filter(fn {k, _} -> k == :eq end)
    |> Enum.reduce(0, fn {_, v}, acc -> String.length(v) + acc end)
    |> case do
      ^expected_length -> [a | acc]
      _ -> acc
    end
  end

  def compare_lines(a, b, acc, expected_length, :binary) do
    common_chars = common_letters(a, b, :binary)

    case String.length(common_chars) do
      ^expected_length -> [a | acc]
      _ -> acc
    end
  end

  def common_letters(a, b, :myers) do
    String.myers_difference(a, b)
    |> Enum.filter(fn {k, _} -> k == :eq end)
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.join("")
  end

  def common_letters(a, b, :binary) do
    do_common_letters_binary(a, b, [])
    |> Enum.reverse()
    |> Enum.join("")
  end

  defp do_common_letters_binary(<<>>, _, acc), do: acc
  defp do_common_letters_binary(_, <<>>, acc), do: acc

  defp do_common_letters_binary(<<c, rest_1::binary>>, <<c, rest_2::binary>>, acc) do
    do_common_letters_binary(rest_1, rest_2, [<<c>> | acc])
  end

  defp do_common_letters_binary(<<_, rest_1::binary>>, <<_, rest_2::binary>>, acc) do
    do_common_letters_binary(rest_1, rest_2, acc)
  end
end
