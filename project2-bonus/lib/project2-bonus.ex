defmodule Project2Bonus do
  @moduledoc """
  Documentation for Project2.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Project2.hello
      :world

  """
  def main(args) do
      {_, [nodes, topology, algo, node_percent, failure_type], _} = OptionParser.parse(args)
      #IO.puts "Building mesh topology"
      IO.puts "command line arguments: #{inspect(nodes)}"
      nodes = elem(Integer.parse(nodes), 0)
      node_percent = elem(Integer.parse(node_percent), 0)
      IO.puts "algo selected: #{algo} topology: #{topology}"
      case topology do
          "full" -> Mesh.build(nodes, :"#{algo}", node_percent, :"#{failure_type}")
          "line" -> Line.build(nodes, :"#{algo}", node_percent, :"#{failure_type}")
          "imp2d" -> Imp2d.build(nodes, :"#{algo}", node_percent, :"#{failure_type}")
          "2d" -> P2D.build(nodes, :"#{algo}", node_percent, :"#{failure_type}")
      end
      #
      #Line.build(nodes)
  end
end
