defmodule Neigbors do
    def assign_neighbours(actors, chunk) do
        clast = length(chunk) - 1
        for {item, cpos} <- Enum.with_index(chunk) do
            last = length(item) - 1
            for {elem, pos} <- Enum.with_index(item) do
                IO.puts "current elem: #{inspect(elem)} at pos: #{pos} last: #{last}"
                # get horrizontal neighbors
                hneighbours = cond do
                        pos == 0 -> [Enum.at(item, 1)]
                        pos == last -> [Enum.at(item, last-1)]
                        true -> [Enum.at(item, pos - 1), Enum.at(item, pos + 1)]
                    end
                # get vertical neighbors
                vneighbours = cond do
                    cpos == 0 -> [Enum.at(Enum.at(chunk, 1), pos)]
                    cpos == clast -> [Enum.at(Enum.at(chunk, clast-1), pos)]
                    true -> [Enum.at(Enum.at(chunk, cpos-1), pos), Enum.at(Enum.at(chunk, cpos+1), pos)]
                end
                # merge the neighbors
                complete_neighbors = List.flatten(hneighbours, vneighbours)
                IO.puts "elem: #{inspect(elem)} neighbours: #{inspect(complete_neighbors)}"
            end
        end
    end
end
l = for n <- 1..16, do: spawn fn -> 1+2 end
chunk = Enum.chunk_every(l, 4)
Neigbors.assign_neighbours(l, chunk)
