defmodule Mesh do
    def build (nodes \\ 3) do
        actors = initialize(nodes)
        # Selecting the first actor as initiator
        [initiator | tail] = actors
        start_time = System.system_time / 1000000000
        intiate(initiator)
        node_count = length(actors)
        listen(node_count)
        time_consumed = (System.system_time / 1000000000) - start_time
        IO.puts "Convergence time: #{time_consumed} nodes count: #{node_count}"
    end
    defp initialize(nodes) do
        for n <- 1..nodes, do: Gossip.start() end
    end
    defp intiate(initiator) do
        send initiator, {:initiate, "Start rumor"}
    end
    defp listen(node_count) do
        for item <- 1..node_count do
            receive do
                {:terminating, from, reason} -> IO.inspect from, label: "Actor terminating reason: #{reason}"
                # code
            end
        end
    end
end