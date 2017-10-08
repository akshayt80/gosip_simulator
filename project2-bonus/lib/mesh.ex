defmodule Mesh do
    def build(nodes, algo, node_percent, failure_type) do
        IO.puts "Creating actors"
        actors = initialize(nodes, algo)
        # Selecting the first actor as initiator
        [initiator | tail] = actors
        node_count = length(actors)
        faulty_node_count = round(node_count * (node_percent / 100))
        if failure_type == :node do
            #node_count = node_count - faulty_node_count
            spawn fn -> kill_nodes(tail, faulty_node_count) end
        else
            spawn fn -> kill_connection(tail, faulty_node_count) end
        end
        termination_count = round(node_count * 0.9)
        start_time = :os.system_time(:millisecond)
        IO.puts "Start time of mesh: #{start_time} initiating with: #{inspect(initiator)}"
        initiate(initiator)
        #node_count = length(actors)
        #listen(actors)
        listen(node_count)
        #listen(0, termination_count)
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
            actors = for n <- 1..nodes, do: spawn fn -> PushSum2.start(parent) end
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
    defp kill_nodes(actors, faulty_node_count) do
        for _ <- 1..faulty_node_count do
            :timer.sleep(5)
            recipient = Enum.random(actors)
            send recipient, {:terminate, :normal}
        end
    end
    defp kill_connection(actors, faulty_node_count) do
        for _ <- 1..faulty_node_count do
            :timer.sleep(5)
            recipient = Enum.random(actors)
            send recipient, {:faulty, :normal}
        end
    end
    # checking if 90% of nodes have converged
    # defp listen(current_count, target_count) when target_count == current_count do
    #     :ok
    # end
    # defp listen(current_count, target_count) do
    #     receive do
    #         {:terminating, from, reason} -> :ok #IO.inspect from, label: "Actor terminating reason: #{reason}"
    #         # code
    #     end
    #     current_count = current_count + 1
    #     listen(current_count, target_count)
    # end
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
