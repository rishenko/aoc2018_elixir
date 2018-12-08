defmodule Aoc2018.DaySeven.StepOrder do
  @doc "Solver for Part 1."
  @spec calculate(any(), any(), any()) :: binary()
  def calculate(graph, dependencies, first_steps) do
    do_calculate(graph, dependencies, first_steps, [])
  end

  defp do_calculate(_, _, [], acc), do: acc |> Enum.reverse() |> Enum.join("")

  defp do_calculate(graph, dependencies, possible_steps, acc) do
    [curr_step | next_steps] = Enum.sort(possible_steps)
    neighbors = :digraph.out_neighbours(graph, curr_step)
    acc = [curr_step | acc]

    neighbor_steps =
      Enum.filter(neighbors, fn neighbor ->
        char_dependencies = Map.get(dependencies, neighbor)
        Enum.all?(char_dependencies, fn char -> char in acc end)
      end)

    do_calculate(graph, dependencies, neighbor_steps ++ next_steps, acc)
  end
end
