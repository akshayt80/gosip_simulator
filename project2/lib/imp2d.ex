defmodule Imp2d do
    def build(nodes \\ 100, algo \\ :pushsum) do
        IO.puts "Creating actors"
        actors = initialize(nodes, algo)
        [initiator | tail] = actors
        # start_time = System.system_time / 1000000000
        # IO.puts "Start time of mesh: #{start_time} initiating with: #{inspect(initiator)}"
        # initiate(initiator)
        # node_count = length(actors)
        # #listen(actors)
        # listen(node_count)
        # time_consumed = (System.system_time / 1000000000) - start_time
        # IO.puts "Convergence time: #{time_consumed} nodes count: #{node_count}"
    end
    defp initialize(nodes, algo) do
        parent = self()
        {node_count, count_per_row} = required_node_count(nodes)
        if algo == :pushsum do
            actors = for n <- 1..node_count, do: spawn fn -> PushSum.start(parent) end
        else
            actors = for n <- 1..node_count, do: spawn fn -> Gossip.start(parent) end 
        end
        #send_neigbours(actors)
        chunks = Enum.chunk_every(actors, count_per_row)
        assign_neighbors(actors, chunks, count_per_row)
        actors
    end
    # round up the node count to have a perfect 2D grid
    defp required_node_count(nodes) do
        x = round Float.ceil(:math.sqrt nodes)
        node_count = x * x
        IO.puts "Changed the node count to: #{node_count}"
        {node_count, x}
    end
    defp assign_neighbors(actors, chunk, count_per_row) do
        clast = count_per_row - 1
        for {item, cpos} <- Enum.with_index(chunk) do
            last = count_per_row - 1
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
                # get some random neighbors
                complete_neighbors = get_random_neighbor(actors, complete_neighbors)
                send_neigbours(elem, complete_neighbors)
                IO.puts "elem: #{inspect(elem)} neighbours: #{inspect(complete_neighbors)}"
            end
        end
    end
    defp get_random_neighbor(actors, complete_neighbors) do
        [random_neighbor] = Enum.take_random(actors, 1)
        # check to not add an element again
        if not(Enum.member?(complete_neighbors, random_neighbor)) do
            complete_neighbors = complete_neighbors ++ [random_neighbor]
        else
            IO.puts "XXX  random is already a part of the neighbors"
        end
        complete_neighbors
    end
    defp send_neigbours(actor, neighbors) do
        IO.inspect actor, label: "sending neighbours to"
        send actor, {:neighbours, neighbors}
    end
    defp initiate(initiator) do
        send initiator, {:initiate, "Start rumor"}
    end
    defp listen(node_count) do
        IO.puts "Current node count: #{node_count}"
        for n <- 1..node_count do
            receive do
                {:terminating, from, reason} -> :ok #IO.inspect from, label: "Actor terminating reason: #{reason}"
                # code
            end
        end
        #listen(node_count)
    end
end