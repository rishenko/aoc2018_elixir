defmodule Aoc2018.DaySeven do
  require Logger

  def line_to_step_tuple(<<"Step ", f::8, " must be finished before step ", l::8, _::binary>>) do
    {<<f>>, <<l>>}
  end

  def find_first_steps(step_tuples) do
    non_first_steps = Enum.map(step_tuples, fn {_, l} -> l end) |> Enum.uniq()

    step_tuples
    |> Enum.filter(fn {f, _} -> f not in non_first_steps end)
    |> Enum.map(fn {f, _} -> f end)
    |> Enum.uniq()
  end

  def build_graph(step_tuples) do
    graph = :digraph.new()

    Enum.each(step_tuples, fn {f, l} ->
      :digraph.add_vertex(graph, f)
      :digraph.add_vertex(graph, l)
      :digraph.add_edge(graph, f, l)
    end)

    graph
  end

  def build_paths(graph, dependencies, first_steps) do
    next_paths(graph, dependencies, first_steps, [])
  end

  def next_paths(_, _, [], acc), do: acc |> Enum.reverse() |> Enum.join("")

  def next_paths(graph, dependencies, possible_steps, acc) do
    [curr_step | possible_next_steps] = Enum.sort(possible_steps)
    neighbors = :digraph.out_neighbours(graph, curr_step)
    acc = [curr_step | acc]

    possible_neighbor_steps =
      Enum.filter(neighbors, fn neighbor ->
        char_dependencies = Map.get(dependencies, neighbor)
        Enum.all?(char_dependencies, fn char -> char in acc end)
      end)

    next_paths(graph, dependencies, possible_neighbor_steps ++ possible_next_steps, acc)
  end

  def build_inverted_dependency_map(step_tuples) do
    Enum.reduce(step_tuples, %{}, fn {f, l}, map ->
      Map.update(map, l, [f], fn deps -> [f | deps] end)
    end)
  end
end
