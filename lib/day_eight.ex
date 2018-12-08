defmodule Aoc2018.DayEight do
  require Logger

  @type record :: {num_nodes, num_metadata_entries, metadata, children}
  @type children :: list(record)
  @type license :: list(integer)
  @type metadata_sum :: integer
  @type metadata :: list(integer)
  @type num_nodes :: integer
  @type num_metadata_entries :: integer

  @spec records_to_tree(license) :: :end_of_license | {record, metadata_sum, license}
  def records_to_tree([]), do: :end_of_license

  def records_to_tree([num_nodes, num_metadata_entries | rest_license]) do
    {children, child_metadata_sum, rest_license} = build_children(num_nodes, rest_license)

    {metadata_entries, rest_license} = Enum.split(rest_license, num_metadata_entries)
    metadata_sum = sum_metadata(metadata_entries) + child_metadata_sum
    {{num_nodes, num_metadata_entries, metadata_entries, children}, metadata_sum, rest_license}
  end

  @spec build_children(integer, list(integer)) :: {children, metadata_sum, license}
  def build_children(0, rest_license), do: {[], 0, rest_license}

  def build_children(num_nodes, rest_license) do
    {children, sum, license} =
      Enum.reduce(
        1..num_nodes,
        {[], 0, rest_license},
        fn _, {children, metadata_sum, license} ->
          {record, child_metadata_sum, license} = records_to_tree(license)
          {[record | children], metadata_sum + child_metadata_sum, license}
        end
      )

    {Enum.reverse(children), sum, license}
  end

  def node_value({0, _, metadata, _}) do
    Enum.reduce(metadata, 0, &(&1 + &2))
  end

  def node_value({_, _, metadata, children}) do
    sum_child_node_values(metadata, children)
  end

  @spec sum_child_node_values(list(metadata), list(record)) :: integer
  def sum_child_node_values(metadata, children) do
    Enum.reduce(metadata, 0, fn index, acc ->
      case Enum.at(children, index - 1, :missing_record) do
        :missing_record -> acc
        child -> node_value(child) + acc
      end
    end)
  end

  def sum_metadata(entries) do
    Enum.reduce(entries, 0, &(&1 + &2))
  end
end
