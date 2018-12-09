defmodule Aoc2018.DaySix do
  require Logger

  @multiple_text "."

  def line_to_coord(line) do
    [x, y] = String.split(line, ", ")
    {String.to_integer(x), String.to_integer(y)}
  end

  def calculate_base_map(coords) do
    {hx, hy} = calculate_bottom_right_point(coords)

    for x <- 0..hx,
        y <- 0..hy do
      {{x, y}, nil, 0, nil}
    end
  end

  def calculate_bottom_right_point(coords) do
    [{x, y} | rest] = Enum.sort(coords)

    {_, hx, _, hy} =
      Enum.reduce(rest, {x, x, y, y}, fn coord, acc ->
        calculate_edge(coord, acc)
      end)

    {hx, hy}
  end

  def calculate_final_area_map(area_list) do
    Enum.map(area_list, fn {loc, _, _, coord} ->
      {loc, coord}
    end)
  end

  def get_finite_results(area_list, hx, hy) do
    coords_to_ignore = gather_ignorable_coords(area_list, hx, hy)
    Enum.filter(area_list, fn {_, coord} -> coord not in coords_to_ignore end)
  end

  def gather_ignorable_coords(area_list, hx, hy) do
    Enum.reduce(area_list, MapSet.new(), fn {{x, y}, coord}, set ->
      if x == 0 or x == hx or y == 0 or y == hy do
        MapSet.put(set, coord)
      else
        set
      end
    end)
  end

  def count_area_by_coord(area_list) do
    Enum.reduce(area_list, %{}, fn {_, coord}, acc ->
      Map.update(acc, coord, 1, fn v -> v + 1 end)
    end)
  end

  def get_coord_with_greatest_area(coord_count_list) do
    Enum.sort(coord_count_list, fn {_, count1}, {_, count2} -> count1 > count2 end) |> hd()
  end

  def build_summed_distance_matrix(coords) do
    area_list = calculate_base_sum_map(coords)
    build_summed_distance_matrix(coords, area_list)
  end

  def build_summed_distance_matrix(coords, area_list) do
    Enum.reduce(coords, area_list, &sum_manhattan_distance(&1, &2))
  end

  def calculate_base_sum_map(coords) do
    {hx, hy} = calculate_bottom_right_point(coords)

    for x <- 0..hx,
        y <- 0..hy do
      {{x, y}, 0}
    end
  end

  def sum_manhattan_distance(coord, area_list) do
    area_list
    |> Enum.map(fn {loc, curr_distance} ->
      distance = manhattan_distance(coord, loc)
      {loc, distance + curr_distance}
    end)
  end

  def build_owning_coord_matrix(coords) do
    area_list = calculate_base_map(coords)
    build_owning_coord_matrix(coords, area_list)
  end

  def build_owning_coord_matrix(coords, area_list) do
    Enum.reduce(coords, area_list, &lowest_coord_distance(&1, &2))
  end

  def lowest_coord_distance(coord, area_list) do
    area_list
    |> Enum.map(fn {loc, curr_dist, count, _} = curr_result ->
      distance = manhattan_distance(coord, loc)

      case curr_dist do
        nil -> {loc, distance, 0, coord}
        curr_dist when distance < curr_dist -> {loc, distance, 0, coord}
        curr_dist when distance == curr_dist -> {loc, distance, count + 1, :multiple}
        _ -> curr_result
      end
    end)
  end

  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def calculate_edge({x, y}, {lx, hx, ly, hy}) do
    {lowest(x, lx), highest(x, hx), lowest(y, ly), highest(y, hy)}
  end

  def lowest(v1, v2) when v1 < v2, do: v1
  def lowest(_, v2), do: v2

  def highest(v1, v2) when v1 > v2, do: v1
  def highest(_, v2), do: v2

  def save_board(file_name, area_list, named_coords, hx, hy, scale) do
    svg = board_to_svg(area_list, named_coords, hx, hy, scale)
    File.write!("./#{file_name}", svg)
  end

  def board_to_svg(area_list, named_coords, hx, hy, scale) do
    width = hx * scale + scale
    height = hy * scale + scale

    """
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
    <svg width="#{width}" height="#{height}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    #{build_board_content(area_list, named_coords, scale)}
    </svg>
    """
  end

  def build_board_content(area_list, named_coords, scale) do
    area_list
    |> Enum.map(fn {loc, coord} -> coord_to_svg(coord, loc, scale, named_coords) end)
    |> Enum.join("\r\n")
  end

  def coord_to_svg(:multiple, l, s, _), do: svg_text_elem(@multiple_text, l, s, false)

  def coord_to_svg(coord, loc, scale, named_coords) do
    named_coords
    |> Map.get(coord)
    |> svg_text_elem(loc, scale, is_origin?(coord, loc))
  end

  def is_origin?(coord1, coord1), do: true
  def is_origin?(_, _), do: false

  def svg_text_elem(text, {x, y}, scale, origin?) do
    x = x * scale
    y = y * scale

    if origin? and text != @multiple_text do
      ~s|
        <text x="#{x}" y="#{y}" font-size="#{scale - 2}" font-weight="bold">#{text}</text>
        <rect x="#{x - div(scale, 4)}" y="#{y - scale + 2}" fill="none" width="#{scale}" height="#{
        scale
      }" style="fill: none; stroke-width: 1; stroke: black;"/>
        |
    else
      ~s|
          <text x="#{x}" y="#{y}" font-size="#{scale - 2}">#{text}</text>
          |
    end
    |> String.trim()
  end
end
