defmodule Mesh do
    def build(nodes \\ 100, algo \\ :gossip) do
        IO.puts "Creating actors"
        actors = initialize(nodes, algo)
        # Selecting the first actor as initiator
        [initiator | tail] = actors
        node_count = length(actors)
        start_time = :os.system_time(:millisecond)
        IO.puts "Start time of mesh: #{start_time} initiating with: #{inspect(initiator)}"
        initiate(initiator)
        #node_count = length(actors)
        #listen(actors)
        listen(node_count)
        time_consumed = :os.system_time(:millisecond) - start_time
        IO.puts "Convergence time: #{time_consumed} nodes count: #{node_count}"
    end
    defp initialize(nodes, algo) do
        parent = self()
        if algo == :gossip do
            IO.puts "Starting gossip"
            actors = for n <- 1..nodes, do: spawn fn -> Gossip.start(parent) end
        else
            IO.puts "Starting push-sum"
            actors = for n <- 1..nodes, do: spawn fn -> PushSum.start(parent) end
        end
        send_neigbours(actors)
        actors
    end
    defp send_neigbours(actors) do
        for n <- actors do
            IO.inspect n, label: "sending neighbours to"
            send n, {:neighbours, actors}
        end
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
    # defp listen(actors) when actors == [] do
    #     :ok
    # end
    # defp listen(actors) do
    #     #new_actors = actors
    #     #IO.puts "actors: #{inspect(actors)}"
    #     actors = Enum.drop_while(actors, fn(x) -> not(Process.alive?(x)) end)
    #     # for actor <- actors do
    #     #     status = Process.alive?(actor)
    #     #     IO.puts "Checking for : #{inspect(actor)} status: #{not(status)}"
    #     #     if not(status) do
    #     #         IO.puts "Deleting"
    #     #         new_actors = List.delete(actors, actor)
    #     #     end
    #     # end
    #     #IO.puts "new actors: #{inspect(new_actors)}"
    #     listen(actors)
    # end
end
