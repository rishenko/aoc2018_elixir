defmodule Aoc2018.DaySeven.StepOrderMultipleWorkers do
  @codepoint_map Enum.map(?A..?Z, &{<<&1>>, &1 - ?A + 1}) |> Enum.into(%{})

  @doc "Solver for Part 2."
  @spec calculate(:digraph.graph(), any(), integer(), [any()]) :: {non_neg_integer(), binary()}
  def calculate(graph, deps, num_workers, first_steps) do
    workers = Enum.map(1..num_workers, &{&1, nil, 0})
    do_calculate(graph, deps, workers, first_steps, {0, []})
  end

  defp do_calculate(graph, deps, workers, possible_steps, {time, acc}) do
    time = time + 1
    {acc_l, workers} = increment_workers(workers)
    acc = acc_l ++ acc
    possible_steps = gather_potential_steps(graph, deps, workers, possible_steps, acc)

    at_end? = length(acc) == length(:digraph.vertices(graph))
    calculate_iteration(graph, deps, workers, possible_steps, at_end?, {time, acc})
  end

  defp calculate_iteration(graph, deps, workers, [], false, {time, acc}) do
    do_calculate(graph, deps, workers, [], {time, acc})
  end

  defp calculate_iteration(graph, deps, workers, possible_steps, false, {time, acc}) do
    {workers, possible_steps} =
      Enum.reduce(workers, {[], possible_steps}, &worker_iteration(&1, &2))

    do_calculate(graph, deps, workers, possible_steps, {time, acc})
  end

  defp calculate_iteration(_, _, _, _, true, {time, acc}) do
    {time - 1, acc |> Enum.reverse() |> Enum.join("")}
  end

  defp worker_iteration(worker, {workers, []}) do
    {[worker | workers], []}
  end

  defp worker_iteration(worker, {workers, possible_steps}) do
    if is_worker_available?(worker) do
      [next_letter | possible_next_steps] = possible_steps
      {id, _, _} = worker
      {[{id, next_letter, 1} | workers], possible_next_steps}
    else
      {[worker | workers], possible_steps}
    end
  end

  defp gather_potential_steps(graph, deps, workers, possible_steps, acc) do
    parent_steps = possible_steps ++ acc

    all_current_neighbors =
      parent_steps
      |> Enum.map(&:digraph.out_neighbours(graph, &1))
      |> List.flatten()
      |> Enum.uniq()

    in_progress_steps = Enum.map(workers, fn {_, l, _} -> l end) |> Enum.filter(&(&1 != nil))
    steps_to_check = Enum.uniq(all_current_neighbors -- (parent_steps ++ in_progress_steps))

    steps_to_check
    |> Enum.filter(fn step ->
      char_dependencies = Map.get(deps, step)
      Enum.all?(char_dependencies, fn char -> char in acc end)
    end)
    |> Kernel.++(possible_steps)
    |> Enum.sort()
  end

  defp increment_workers(workers) do
    Enum.reduce(workers, {[], []}, fn worker, {acc_l, acc_w} ->
      {id, letter, time_spent} = worker

      if is_worker_finished?(worker) do
        if letter == nil do
          {acc_l, [{id, nil, 0} | acc_w]}
        else
          {[letter | acc_l], [{id, nil, 0} | acc_w]}
        end
      else
        {acc_l, [{id, letter, time_spent + 1} | acc_w]}
      end
    end)
  end

  def is_worker_finished?({_, nil, _}), do: true

  def is_worker_finished?({_, letter, time_spent}) do
    req_time = Map.get(@codepoint_map, letter) + 60
    req_time == time_spent
  end

  defp is_worker_available?({_, letter, _}) do
    letter == nil
  end
end
