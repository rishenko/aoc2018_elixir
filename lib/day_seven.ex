defmodule Aoc2018.DaySeven do
  require Logger

  @codepoint_map Enum.map(?A..?Z, &{<<&1>>, &1 - ?A + 1}) |> Enum.into(%{})

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

  def build_paths_by_time(graph, dependencies, num_workers, first_steps) do
    workers = Enum.map(1..num_workers, &{&1, nil, 0})
    next_paths_by_time(graph, dependencies, 0, workers, first_steps, [])
  end

  def next_paths_by_time(graph, dependencies, time, workers, possible_steps, acc) do
    time = time + 1
    {acc_l, workers} = increment_work(workers)
    acc = acc_l ++ acc
    possible_steps = get_possible_next_steps(graph, dependencies, workers, possible_steps, acc)

    case length(acc) == length(:digraph.vertices(graph)) do
      false ->
        case possible_steps do
          [] ->
            next_paths_by_time(graph, dependencies, time, workers, [], acc)

          possible_steps ->
            {workers, possible_steps} =
              Enum.reduce(workers, {[], possible_steps}, fn
                worker, {workers, []} ->
                  {[worker | workers], []}

                worker, {workers, possible_steps} ->
                  case is_worker_available?(worker) do
                    false ->
                      {[worker | workers], possible_steps}

                    true ->
                      [next_letter | possible_next_steps] = possible_steps
                      {id, _, _} = worker
                      {[{id, next_letter, 1} | workers], possible_next_steps}
                  end
              end)

            next_paths_by_time(graph, dependencies, time, workers, possible_steps, acc)
        end

      true ->
        {time - 1, acc |> Enum.reverse() |> Enum.join("")}
    end
  end

  def get_possible_next_steps(graph, dependencies, workers, possible_steps, acc) do
    parent_steps = possible_steps ++ acc

    all_current_neighbors =
      Enum.map(parent_steps, &:digraph.out_neighbours(graph, &1)) |> List.flatten() |> Enum.uniq()

    in_progress_steps = Enum.map(workers, fn {_, l, _} -> l end) |> Enum.filter(&(&1 != nil))
    steps_to_remove = parent_steps ++ in_progress_steps
    steps_to_check = Enum.uniq(all_current_neighbors -- steps_to_remove)

    possible_steps =
      Enum.filter(steps_to_check, fn step ->
        char_dependencies = Map.get(dependencies, step)
        Enum.all?(char_dependencies, fn char -> char in acc end)
      end) ++ possible_steps

    Enum.sort(possible_steps)
  end

  def give_worker_task(workers, id, curr_step) do
    Enum.map(workers, fn {w_id, _, _} = worker ->
      if w_id == id do
        {id, curr_step, 1}
      else
        worker
      end
    end)
  end

  def increment_work(workers) do
    Enum.reduce(workers, {[], []}, fn worker, {acc_l, acc_w} ->
      {id, letter, time_spent} = worker

      case is_worker_finished?(worker) do
        false ->
          {acc_l, [{id, letter, time_spent + 1} | acc_w]}

        true ->
          if letter == nil do
            {acc_l, [{id, nil, 0} | acc_w]}
          else
            {[letter | acc_l], [{id, nil, 0} | acc_w]}
          end
      end
    end)
  end

  def is_worker_finished?({_, nil, _}), do: true

  def is_worker_finished?({_, letter, time_spent}) do
    req_time = Map.get(@codepoint_map, letter) + 60
    req_time == time_spent
  end

  def available_workers(workers) do
    Enum.filter(workers, &is_worker_available?(&1))
  end

  def is_worker_available?({_, letter, _}) do
    letter == nil
  end

  def build_inverted_dependency_map(step_tuples) do
    Enum.reduce(step_tuples, %{}, fn {f, l}, map ->
      Map.update(map, l, [f], fn deps -> [f | deps] end)
    end)
  end
end
