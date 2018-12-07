contents_2 = ["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"]

contents_2
|> DayThree.line_list_to_rectangles()
|> DayThree.count_overlapping_squares()
|> Enum.filter(fn {_, v} -> v >= 2 end)

rectangles =
  File.read!("priv/day_three_input.txt")
  |> String.trim()
  |> String.split("\n")
  |> DayThree.line_list_to_rectangles()

assert 117_948 ==
         rectangles
         |> DayThree.count_overlapping_squares()
         |> Enum.filter(fn {_, v} -> v >= 2 end)
         |> Enum.map(fn {k, _} -> k end)
         |> length()

assert 567 =
         DayThree.find_overlapping_rectangles_by_corners(rectangles, 0)
         |> Enum.map(fn {id, _} -> id end)
         |> hd()

alias Aoc2018.DayFour

example_data =
  """
  [1518-11-01 00:00] Guard #10 begins shift
  [1518-11-01 00:05] falls asleep
  [1518-11-01 00:25] wakes up
  [1518-11-01 00:30] falls asleep
  [1518-11-01 00:55] wakes up
  [1518-11-01 23:58] Guard #99 begins shift
  [1518-11-02 00:40] falls asleep
  [1518-11-02 00:50] wakes up
  [1518-11-03 00:05] Guard #10 begins shift
  [1518-11-03 00:24] falls asleep
  [1518-11-03 00:29] wakes up
  [1518-11-04 00:02] Guard #99 begins shift
  [1518-11-04 00:36] falls asleep
  [1518-11-04 00:46] wakes up
  [1518-11-05 00:03] Guard #99 begins shift
  [1518-11-05 00:45] falls asleep
  [1518-11-05 00:55] wakes up
  """
  |> String.trim()
  |> String.split("\n")

sorted_results =
  Enum.reduce(example_data, {nil, []}, fn line, {guard_id, acc} ->
    {curr_guard_id, _, _} = entry = Aoc2018.DayFour.parse_line(line, guard_id)
    {curr_guard_id, [entry | acc]}
  end)
  |> elem(1)
  |> DayFour.sort_events()

result_map =
  Enum.reduce(example_data, {nil, %{}}, fn line, {prev_guard_id, acc} ->
    {guard_id, time, entry} = Aoc2018.DayFour.parse_line(line, prev_guard_id)
    {guard_id, Map.update(acc, guard_id, [], fn entries -> [{time, entry} | entries] end)}
  end) |> elem(1)

result_map |> Enum.map(fn {guard_id, events} ->
    events = Enum.sort(events)
    {guard_id, events}
end) |> Enum.into(%{})

result_map |> Enum.map(fn {guard_id, events} ->
  {guard_id, DayFour.guard_sleep_calculator(Enum.sort(events), {0, %{}})}
end) |> Enum.into(%{})





contents = "priv/day_four_input.txt" |> File.read!() |> String.trim() |> String.split("\n")
contents = example_data

results =
  Enum.reduce(contents, {nil, []}, fn line, {guard_id, acc} ->
    {curr_guard_id, _, _} = entry = Aoc2018.DayFour.parse_line(line)
    {curr_guard_id, [entry | acc]}
  end) |> elem(1) |> DayFour.sort_events()

complete_results =
  Enum.reduce(results, {nil, []}, fn event, {prev_guard_id, acc} ->
    {guard_id, timestamp, status} = event
    if prev_guard_id != nil and guard_id == nil do
      {prev_guard_id, [{prev_guard_id, timestamp, status} | acc]}
    else
      {guard_id, [event | acc]}
    end
  end) |> elem(1)

calculated_metrics = DayFour.calculate_guard_metrics(complete_results)

sorted_metrics = Enum.sort(calculated_metrics, fn {_, {total_1, _}}, {_, {total_2, _}} ->
  total_1 > total_2
end)

{id, {total, minute_map}} = hd(sorted_metrics)
{c, m} = Enum.map(minute_map, fn {k, v} -> {v, k} end) |> Enum.sort(& &1 > &2) |> hd()
{m, c}
21956 = id * m # Part 1

guard_minute_count = DayFour.metrics_to_minutes(sorted_metrics) |> Enum.sort(fn {_, _, c_1}, {_, _, c_2} -> c_1 > c_2 end)



# Day Five
alias Aoc2018.DayFive
example_data = "dabAcCaCBAcCcaDA"
contents = "priv/day_five_input.txt" |> File.read!() |> String.trim()

11546 = DayFive.react_polymer(contents) # Solution to Part 1

"dbCBcD" = example_data |> DayFive.remove_units([?a,?A]) |> DayFive.react_polymer()
"abCBAc" = example_data |> DayFive.remove_units([?d,?D]) |> DayFive.react_polymer()

5124 = DayFive.build_metrics_removed_units(contents) |> Enum.map(fn {cnt, l, _} -> {cnt, l} end) |> hd() |> elem(0) # Problem 2 solution


# Day Six
alias Aoc2018.DaySix

## Example Data
example_data = """
1, 1
1, 6
8, 3
3, 4
5, 5
8, 9
""" |> String.trim()
example_data_coords = example_data |> String.split("\n") |> Enum.map(&DaySix.line_to_coord(&1))
example_data_coords_named = Enum.zip(?A..?A+length(example_data_coords)-1, example_data_coords) |> Enum.map(fn {n, l} -> {l, <<n>>} end) |> Enum.into(%{})
{br_x, br_y} = DaySix.calculate_bottom_right_point(example_data_coords)
area_map = DaySix.build_coord_manhattan_distance(example_data_coords)
final_area_map = DaySix.calculate_final_area_map(area_map)
scale = 30
DaySix.save_board("area_map.svg", final_area_map, example_data_coords_named, br_x, br_y, scale)

## Input Data
day_six_coords = "priv/day_six_input.txt" |> File.read!() |> String.trim() |> String.split("\n") |> Enum.map(&DaySix.line_to_coord(&1))
day_six_coords_named = Enum.zip(?A..?A+length(day_six_coords)-1, day_six_coords) |> Enum.map(fn {n, l} -> {l, <<n>>} end) |> Enum.into(%{})
{br_x, br_y} = DaySix.calculate_bottom_right_point(day_six_coords)
day_six_area_map = DaySix.build_coord_manhattan_distance(day_six_coords)
day_six_final_area_map = DaySix.calculate_final_area_map(day_six_area_map)
scale = 30
DaySix.save_board("day_six_area_map.svg", day_six_final_area_map, day_six_coords_named, br_x, br_y, scale)
finite_results = DaySix.get_finite_results(day_six_final_area_map, br_x, br_y)
finite_coord_count = DaySix.count_area_by_coord(finite_results)
{loc, 4016} = DaySix.get_coord_with_greatest_area(finite_coord_count)
