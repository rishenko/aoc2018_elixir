defmodule Aoc2018.DayFive do
  def react_polymer(str) do
    do_react_polymer(str, 0, [])
  end

  @codepoints Enum.zip(Enum.to_list(?a..?z), Enum.to_list(?A..?Z))

  def do_react_polymer(<<>>, cnt, acc) when cnt > 0 do
    acc |> Enum.reverse() |> Enum.join("") |> do_react_polymer(0, [])
  end

  def do_react_polymer(<<>>, 0, acc), do: acc |> Enum.reverse() |> Enum.join("")

  for {l, u} <- @codepoints do
    def do_react_polymer(<<unquote(l), unquote(u), rest::binary>>, cnt, acc) do
      do_react_polymer(rest, cnt + 1, acc)
    end

    def do_react_polymer(<<unquote(u), unquote(l), rest::binary>>, cnt, acc) do
      do_react_polymer(rest, cnt + 1, acc)
    end
  end

  def do_react_polymer(<<x::bytes-size(1), rest::binary>>, cnt, acc) do
    do_react_polymer(rest, cnt, [x | acc])
  end

  def remove_units(str, units) do
    str
    |> to_charlist()
    |> Enum.reduce([], fn c, acc ->
      if c in units do
        acc
      else
        [c | acc]
      end
    end)
    |> Enum.reverse()
    |> to_string()
  end

  def build_metrics_removed_units(str) do
    Enum.reduce(@codepoints, [], fn {l, u}, acc ->
      result =
        str
        |> remove_units([l, u])
        |> react_polymer()

      [{String.length(result), <<l>>, result} | acc]
    end)
    |> Enum.sort()
  end
end
