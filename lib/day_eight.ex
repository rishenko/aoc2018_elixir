defmodule Aoc2018.DayEight do
  require Logger
  def records_to_tree([]), do: :end_of_license

  def records_to_tree([num_nodes, num_metadata_entries | rest_license]) do
    if num_nodes == 0 do
      {metadata_entries, rest_license} = Enum.split(rest_license, num_metadata_entries)
      metadata_sum = calc_metadata_entries(metadata_entries)
      {{0, num_metadata_entries, metadata_entries, []}, metadata_sum, rest_license}
    else
      {children, child_metadata_sum, rest_license} =
        Enum.reduce(
          1..num_nodes,
          {[], 0, rest_license},
          fn _, {children, metadata_sum, license} ->
            case records_to_tree(license) do
              :end_of_license ->
                {children, metadata_sum, license}

              {record, child_metadata_sum, license} ->
                {[record | children], metadata_sum + child_metadata_sum, license}
            end
          end
        )
      {metadata_entries, rest_license} = Enum.split(rest_license, num_metadata_entries)
      metadata_sum = calc_metadata_entries(metadata_entries) + child_metadata_sum
      {{num_nodes, num_metadata_entries, metadata_entries, children}, metadata_sum, rest_license}
    end
  end

  def calc_metadata_entries(entries) do
    Enum.reduce(entries, 0, &(&1 + &2))
  end
end
