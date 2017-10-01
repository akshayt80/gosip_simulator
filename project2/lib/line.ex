defmodule Line do
    def build(nodes \\ 100) do
        IO.puts "Creating actors"
        {actors, initiator} = initialize(nodes)
        start_time = System.system_time / 1000000000
        IO.puts "Start time of mesh: #{start_time} initiating with: #{inspect(initiator)}"
        initiate(initiator)
        node_count = length(actors)
        #listen(actors)
        listen(node_count)
        time_consumed = (System.system_time / 1000000000) - start_time
        IO.puts "Convergence time: #{time_consumed} nodes count: #{node_count}"
    end
    defp initialize(nodes) do
        parent = self()
        actors = for n <- 1..nodes, do: spawn fn -> Gossip.start(parent) end
        initiator = assign_neighbours(actors)
        {actors, initiator}
    end
    defp assign_neighbours(actors) do
        first = List.first actors
        second = Enum.at actors, 1
        send_neigbours(first, [second])
        chunks = Enum.chunk_every(actors, 3, 1)
        for chunk <- chunks do
            IO.puts "length of chunk: #{length(chunk)}"
            if length(chunk) == 3 do
                [left, actor, right] = chunk
                send_neigbours(actor, [left, right])
            else
                [left, actor] = chunk
                send_neigbours(actor, [left])
            end
        end
        first
    end
    defp send_neigbours(actor, neighbours) do
        IO.inspect actor, label: "sending neighbours to"
        send actor, {:neighbours, neighbours}
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