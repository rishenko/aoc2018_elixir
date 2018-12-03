defmodule Aoc2018.DayThree do
  @type rect :: {point, point, point, point}
  @type point :: {integer, integer}

  def line_list_to_rectangles(line_list) do
    Enum.map(line_list, &line_to_rectangle(&1))
  end

  @doc """
  Convert a line to a rectangle, where each line is formatted as follows:
  `#<id> @ <x>,<y>: <w>,<h>`

  Example: #933 @ 149,439: 22x27
  """
  def line_to_rectangle(line) do
    [_, id, x, y, w, h] = Regex.run(~r/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/, line)
    x = String.to_integer(x)
    y = String.to_integer(y)
    x2 = x + String.to_integer(w)
    y2 = y + String.to_integer(h)
    {String.to_integer(id), {x, y}, {x2, y}, {x, y2}, {x2, y2}}
  end

  def rectangle_area_square_overlap(rect_1, rect_2, area_square) do
    # locate point that overlaps
    # calculate line intersections from that point
    # use intersection points to see if distance is at least 2 in both directions
  end

  def find_overlapping_rectangles(rect_list, num_overlaps) do
    Enum.reduce(rect_list, [], fn rect, acc ->
      case num_overlapping_rectangles(rect, rect_list) do
        num when num >= num_overlaps -> [{elem(rect, 0), num} | acc]
        _ -> acc
      end
    end)
  end

  def num_overlapping_rectangles(rect, rect_list) do
    Enum.reduce(
      rect_list,
      0,
      &rectangle_overlap(rect, &1, &2)
    )
  end

  def rectangle_overlap(rect_1, rect_1, acc), do: acc

  def rectangle_overlap(rect_1, rect_2, acc) do
    if rectangle_in_rectangle?(rect_1, rect_2) do
      acc + 1
    else
      acc
    end
  end

  def rectangle_in_rectangle?({_, tl, tr, bl, br}, {_, tl_2, _, _, br_2}) do
    with false <- point_in_rectangle?(tl, tl_2, br_2),
         false <- point_in_rectangle?(tr, tl_2, br_2),
         false <- point_in_rectangle?(bl, tl_2, br_2),
         false <- point_in_rectangle?(br, tl_2, br_2) do
      false
    else
      _ -> true
    end
  end

  def point_in_rectangle?({x, y}, {xl, yt}, {xr, yb}) do
    if xl <= x and x <= xr and yt <= y and y <= yb do
      true
    else
      false
    end
  end
end
