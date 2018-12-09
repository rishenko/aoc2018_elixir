defmodule Aoc2018.DayFour do
  require Logger

  def parse_line(
        <<"[", year::bytes-size(4), "-", month::bytes-size(2), "-", day::bytes-size(2), _::8,
          hour::bytes-size(2), ":", min::bytes-size(2), "] ", rest::binary>>
      ) do
    {:ok, timestamp} =
      NaiveDateTime.new(
        String.to_integer(year),
        String.to_integer(month),
        String.to_integer(day),
        String.to_integer(hour),
        String.to_integer(min),
        0
      )

    rest |> String.trim() |> create_entry(timestamp, nil)
  end

  def create_entry(<<"falls asleep">>, timestamp, guard_id) do
    {guard_id, timestamp, :asleep}
  end

  def create_entry(<<"wakes up">>, timestamp, guard_id) do
    {guard_id, timestamp, :awake}
  end

  def create_entry(<<"Guard #", rest::binary>>, timestamp, _) do
    id = get_first_number(rest, [])
    {id, timestamp, :shift_begins}
  end

  for n <- ?0..?9 do
    def get_first_number(<<unquote(n), rest::binary>>, acc) do
      get_first_number(rest, [unquote(n) | acc])
    end
  end

  def get_first_number(_, acc), do: acc |> Enum.reverse() |> to_string() |> String.to_integer()

  def guard_sleep_calculator([], {total, minute_map}), do: {div(total, 60), minute_map}

  def guard_sleep_calculator([{time_1, :asleep}, {time_2, :awake} | events], {total, minute_map}) do
    diff_seconds = NaiveDateTime.diff(time_2, time_1)
    acc = {total + diff_seconds, build_minute_map(minute_map, time_1, diff_seconds)}
    guard_sleep_calculator(events, acc)
  end

  def guard_sleep_calculator([_ | events], acc), do: guard_sleep_calculator(events, acc)

  def sort_events(events) do
    Enum.sort(events, fn {_, time_1, _}, {_, time_2, _} ->
      NaiveDateTime.compare(time_1, time_2) == :lt
    end)
  end

  def calculate_guard_metrics(results) do
    results
    |> sort_events()
    |> guard_metrics(%{})
  end

  def guard_metrics([], acc), do: acc

  def guard_metrics([{id_1, time_1, :asleep}, {id_1, time_2, :awake} | events], acc) do
    diff_seconds = NaiveDateTime.diff(time_2, time_1)
    updated_metrics = update_guard_metrics(acc, id_1, diff_seconds, time_1)
    guard_metrics(events, updated_metrics)
  end

  def guard_metrics([{id_1, time_1, :asleep}, {_, time_2, :shift_begins} | events], acc) do
    diff_seconds = NaiveDateTime.diff(time_2, time_1)
    updated_metrics = update_guard_metrics(acc, id_1, diff_seconds, time_1)
    guard_metrics(events, updated_metrics)
  end

  def guard_metrics([{_, _, :shift_begins} | events], acc), do: guard_metrics(events, acc)

  def guard_metrics([event_1, event_2 | events], acc) do
    Logger.warn("unexpected events: #{inspect(event_1)} AND #{inspect(event_2)}")
    guard_metrics(events, acc)
  end

  def update_guard_metrics(acc, id, diff_seconds, time_1) do
    default_value = {diff_seconds, build_minute_map(%{}, time_1, diff_seconds)}

    Map.update(acc, id, default_value, fn {total, minute_map} ->
      {total + diff_seconds, build_minute_map(minute_map, time_1, diff_seconds)}
    end)
  end

  def build_minute_map(minute_map, time_1, diff_seconds) do
    minute = time_1.minute
    diff_minutes = div(diff_seconds, 60) - 1

    Enum.reduce(minute..(minute + diff_minutes), minute_map, fn min, map ->
      Map.update(map, rem(min, 60), 1, fn c -> c + 1 end)
    end)
  end

  def metrics_to_minutes(metrics) do
    Enum.reduce(metrics, [], fn {id, {_, minute_map}}, acc ->
      Enum.map(minute_map, fn {m, c} ->
        {id, m, c}
      end) ++ acc
    end)
  end
end
