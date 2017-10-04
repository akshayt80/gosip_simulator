defmodule Project2 do
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
      {_, [nodes, algo, topology], _} = OptionParser.parse(args)
      #IO.puts "Building mesh topology"
      IO.puts "command line arguments: #{inspect(nodes)}"
      nodes = elem(Integer.parse(nodes), 0)
      IO.puts "algo selected: #{algo} topology: #{topology}"
      case algo do
          "full" -> Mesh.build(nodes, :"#{topology}")
          "line" -> Line.build(nodes, :"#{topology}")
          "imp2d" -> Imp2d.build(nodes, :"#{topology}")
          "2d" -> IO.puts "Not yet implemented"
      end
      #
      #Line.build(nodes)
  end
end
