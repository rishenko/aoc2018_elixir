defmodule Aoc2018.DaySix do
  require Logger

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

  def calculate_final_area_map(area_map) do
    Enum.map(area_map, fn {loc, _, _, coord} ->
      {loc, coord}
    end)
  end

  def build_coord_manhattan_distance(coords) do
    area_list = calculate_base_map(coords)
    build_coord_manhattan_distance(coords, area_list)
  end

  def build_coord_manhattan_distance(coords, area_list) do
    Enum.reduce(coords, area_list, &add_coord_distances(&1, &2))
  end

  def add_coord_distances(coord, area_list) do
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

  def save_board(file_name, area_map, named_coords, hx, hy, scale) do
    svg = board_to_svg(area_map, named_coords, hx, hy, scale)
    File.write!("./#{file_name}", svg)
  end

  def board_to_svg(area_map, named_coords, hx, hy, scale) do
    width = hx*scale
    height = hy*scale
    content =
      Enum.map(area_map, fn {loc, coord} ->
        case coord do
          :multiple ->
            svg_text_elem(".", loc, scale, "normal")

          coord ->
            weight = get_weight(coord, loc)

            named_coords
            |> Map.get(coord)
            |> svg_text_elem(loc, scale, weight)
        end
      end)
      |> Enum.join("\r\n")

    """
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
    <svg width="#{width}" height="#{height}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    #{content}
    </svg>
    """
  end

  def get_weight(coord1, coord1), do: "bold"
  def get_weight(_, _), do: "normal"

  def svg_text_elem(text, {x, y}, scale, weight) do
    x = x * scale
    y = y * scale
    case weight do
      "normal" ->
        ~s|
        <text x="#{x}" y="#{y}" font-size="#{scale - 2}">#{
          text
        }</text>
        |

      "bold" ->
        ~s|
        <text x="#{x}" y="#{y}" font-size="#{scale - 2}" font-weight="bold">#{text}</text>
        <rect x="#{x-div(scale, 4)}" y="#{y-scale+2}" fill="none" width="#{scale}" height="#{scale}" style="fill: none; stroke-width: 1; stroke: black;"/>
        |
    end

  end
end
