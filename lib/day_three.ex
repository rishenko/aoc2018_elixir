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
    x2 = x + String.to_integer(w) - 1
    y2 = y + String.to_integer(h) - 1
    {String.to_integer(id), {x, y}, {x2, y}, {x, y2}, {x2, y2}}
  end

  def count_overlapping_squares(rectangles) do
    Enum.reduce(rectangles, %{}, fn {_, {x_1, y_1}, _, _, {x_2, y_2}}, acc ->
      for x <- x_1..x_2,
          y <- y_1..y_2 do
        {x, y}
      end
      |> Enum.reduce(acc, &Map.update(&2, &1, 1, fn v -> v + 1 end))
    end)
  end

  def count_overlapping_rectangles(rect_list, num_overlaps, min_square_area) do
    Enum.reduce(rect_list, [], fn rect, final_rects ->
      Enum.reduce(rect_list, 0, fn rect_2, count ->
        if rectangle_overlap_at_least?(rect, rect_2, min_square_area) do
          count + 1
        else
          count
        end
      end)
      |> case do
        n when n < num_overlaps -> final_rects
        _ -> [rect | final_rects]
      end
    end)
  end

  def rectangle_overlap_at_least?(rect_1, rect_2, area_square) do
    case rectangle_in_rectangle(rect_1, rect_2) do
      :not_in_rectangle ->
        false

      point ->
        square_area_at_least?(point, rect_1, rect_2, area_square)
    end
  end

  def square_area_at_least?(
        {x_1, y_1},
        {_, {x_1, y_1}, _, _, _},
        {_, _, _, _, {x_2, y_2}},
        area_square
      ) do
    x_2 - x_1 >= area_square and y_2 - y_1 >= area_square
  end

  def square_area_at_least?(
        {x_1, y_1},
        {_, _, {x_1, y_1}, _, _},
        {_, _, _, {x_2, y_2}, _},
        area_square
      ) do
    x_1 - x_2 >= area_square and y_2 - y_1 >= area_square
  end

  def square_area_at_least?(
        {x_1, y_1},
        {_, _, _, {x_1, y_1}, _},
        {_, _, {x_2, y_2}, _, _},
        area_square
      ) do
    x_2 - x_1 >= area_square and y_1 - y_2 >= area_square
  end

  def square_area_at_least?(
        {x_1, y_1},
        {_, _, _, _, {x_1, y_1}},
        {_, {x_2, y_2}, _, _, _},
        area_square
      ) do
    x_1 - x_2 >= area_square and y_1 - y_2 >= area_square
  end

  def difference_at_least({x_1, y_1}, {x_2, y_2}, area_square) do
    x_2 - x_1 >= area_square and y_2 - y_1 >= area_square
  end

  def rectangle_in_rectangle({_, tl, tr, bl, br}, {_, tl_2, _, _, br_2}) do
    with :not_in_rectangle <- point_in_rectangle(tl, tl_2, br_2),
         :not_in_rectangle <- point_in_rectangle(tr, tl_2, br_2),
         :not_in_rectangle <- point_in_rectangle(bl, tl_2, br_2),
         :not_in_rectangle <- point_in_rectangle(br, tl_2, br_2) do
      :not_in_rectangle
    else
      point -> point
    end
  end

  def point_in_rectangle({x, y} = point, {xl, yt}, {xr, yb}) do
    if xl <= x and x <= xr and yt <= y and y <= yb do
      point
    else
      :not_in_rectangle
    end
  end

  def find_overlapping_rectangles_by_corners(rect_list, num_overlaps) do
    Enum.reduce(rect_list, [], fn rect, acc ->
      case num_overlapping_rectangles(rect, rect_list) do
        num when num == num_overlaps -> [{elem(rect, 0), num} | acc]
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
    if rectangle_in_rectangle?(rect_1, rect_2) or rectangle_in_rectangle?(rect_2, rect_1) do
      acc + 1
    else
      acc
    end
  end

  def rectangle_in_rectangle?({_, tl, tr, bl, br}, {_, tl_2, _, _, br_2}) do
    with false <- point_in_rectangular_area?(tl, tl_2, br_2),
         false <- point_in_rectangular_area?(tr, tl_2, br_2),
         false <- point_in_rectangular_area?(bl, tl_2, br_2),
         false <- point_in_rectangular_area?(br, tl_2, br_2) do
      false
    else
      _ -> true
    end
  end

  def point_in_rectangular_area?({x, y}, {xl, yt}, {xr, yb}) do
    if xl <= x and x <= xr and yt <= y and y <= yb do
      true
    else
      false
    end
  end
end
