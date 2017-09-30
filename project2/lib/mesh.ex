defmodule Mesh do
    def build (nodes \\ 100) do
        IO.puts "Creating actors"
        actors = initialize(nodes)
        # Selecting the first actor as initiator
        [initiator | tail] = actors
        start_time = System.system_time / 1000000000
        IO.puts "Start time of mesh: #{start_time} initiating with: #{inspect(initiator)}"
        intiate(initiator)
        node_count = length(actors)
        #listen(actors)
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
