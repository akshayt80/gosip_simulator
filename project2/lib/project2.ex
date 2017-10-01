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
      {_, [str], _} = OptionParser.parse(args)
      IO.puts "Building mesh topology"
      nodes = elem(Integer.parse(str), 0)
      #Mesh.build(nodes)
      Line.build(nodes)
  end
end
