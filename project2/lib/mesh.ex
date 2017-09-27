defmodule Mesh do
    def build (nodes \\ 3) do
        IO.puts "Creating actors"
        actors = initialize(nodes)
        # Selecting the first actor as initiator
        [initiator | tail] = actors
        start_time = System.system_time / 1000000000
        IO.puts "Start time of mesh: #{start_time}"
        intiate(initiator)
        node_count = length(actors)
        listen(node_count)
        time_consumed = (System.system_time / 1000000000) - start_time
        IO.puts "Convergence time: #{time_consumed} nodes count: #{node_count}"
    end
    defp initialize(nodes) do
        parent = self()
        actors = for n <- 1..nodes, do: spawn fn -> Gossip.start(parent) end
        send_neigbours(actors)
        actors
    end
    defp send_neigbours(actors) do
        for n <- actors do
            IO.inspect n, label: "sending neighbours to"
            send n, {:neighbours, actors}
        end
    end
    defp intiate(initiator) do
        send initiator, {:initiate, "Start rumor"}
    end
    defp listen(node_count) do
        node_count = receive do
                {:terminating, from, reason} -> IO.inspect from, label: "Actor terminating reason: #{reason}"
                    node_count - 1
                # code
        end
        listen(node_count)
    end
    defp listen(0) do
        :ok
    end
end
