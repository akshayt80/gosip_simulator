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
                #neighbour_count = length(complete_neighbors)
                complete_neighbors = get_random_neighbor(actors, complete_neighbors) #get_random_neighbor(actors, complete_neighbors, neighbour_count, neighbour_count+1)
                IO.puts "elem: #{inspect(elem)} neighbours: #{inspect(complete_neighbors)}"
            end
        end
    end
    defp get_random_neighbor(actors, complete_neighbors) do
        random_neighbor = Enum.take_random(actors, 1)
        # check to not add an element again
        if not(Enum.member?(complete_neighbors, random_neighbor)) do
            complete_neighbors = complete_neighbors ++ random_neighbor
        end
        complete_neighbors
    end
    # defp get_random_neighbor(actors, complete_neighbors, neighbour_count, required_count)
    #                                             when neighbour_count == required_count do
    #     complete_neighbors
    # end
    # defp get_random_neighbor(actors, complete_neighbors, neighbour_count, required_count) do
    #     random_neighbor = Enum.take_random(actors, 1)
    #     if not(Enum.member?(complete_neighbors, random_neighbor)) do
    #        complete_neighbors = List.flatten(complete_neighbors, [random_neighbor]) 
    #     end
    #     neighbour_count = length(complete_neighbors)
    #     IO.puts "neighbour_count: #{neighbour_count}, required_count: #{required_count}"
    #     get_random_neighbor(actors, complete_neighbors, neighbour_count, required_count)
    # end
end
l = for n <- 1..16, do: spawn fn -> 1+2 end
chunk = Enum.chunk_every(l, 4)
Neigbors.assign_neighbours(l, chunk)
