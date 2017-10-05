defmodule Gossip do
    def start(parent) do
        neighbours = []
        rumor_count = 0
        send_msg_pid = 0
        listen(neighbours, rumor_count, parent, send_msg_pid)
    end
    defp listen(neighbours, rumor_count, parent, send_msg_pid, terminated \\ false) do
        #IO.puts "start listening: #{inspect(self())}"
        receive do
            {:neighbours, neighbour_list} -> neighbours = set_neighbours(neighbour_list)
                IO.inspect neighbours, label: "Registered neighbours"
            {:rumor, from, message} -> {rumor_count, neighbours, terminated, send_msg_pid} = handle_rumors(message, rumor_count, neighbours, from, parent, send_msg_pid, terminated)
            {:initiate, value} -> neighbours = send_rumor("secret message", neighbours)
        after
            100 -> check_active_neighbours(neighbours, parent, send_msg_pid)
        end
        listen(neighbours, rumor_count, parent, send_msg_pid, terminated)
    end
    defp check_active_neighbours(neighbours, parent, send_msg_pid) do
        # make sure that the initialization of the node is done
        # as  after initialization it will have non zero neigbours
        if length(neighbours) != 0 do
            {recipients, neighbours} = get_active_neighbours(neighbours, MapSet.new, 0, 1, length(neighbours))
            if neighbours == [] do
                #IO.puts "No active neighbours left: #{inspect(self())}"
                terminate(parent, send_msg_pid)
            end
        end
    end
    defp set_neighbours(neighbours) do
        List.delete(neighbours, self())
    end
    defp handle_rumors(message, count, neighbours, from, parent, send_msg_pid, terminated \\ false, terminate_count \\ 10) do
        #IO.puts "Received rumor from: #{inspect(from)} to: #{inspect(self())}"
        count = count + 1
        #IO.puts "pid= #{inspect(self())} count= #{count} terminate_count= #{terminate_count}"
        if count >=  terminate_count or terminated do
            # Last message
            if not(terminated) do
                #send_rumor(message, neighbours, 5)
                # 
                #terminate(parent)
                terminate(parent, send_msg_pid)
                terminated = true
            end
        else
            # neighbours = send_rumor(message, neighbours)
            # if neighbours == [] do
            #     terminate(parent)
            #     terminate = true
            # end
            if send_msg_pid == 0 do
                IO.puts "Assigning send_msg_pid: #{inspect(self())}"
                send_msg_pid = spawn fn -> continuously_send_rumor(message, neighbours) end
            end
        end
        {count, neighbours, terminated, send_msg_pid}
    end
    defp continuously_send_rumor(message, neighbours) do
        send_rumor(message, neighbours)
        # sleep
        :timer.sleep(50)
        continuously_send_rumor(message, neighbours)
    end
    defp send_rumor(message, neighbours, stop_count \\ 1) do
        # Testing to not kill nodes after n
        #recipients = get_random_neighbours(neighbours)
        #TODO:- active recipient always goes through all the neigbours to select an active one
        #IO.puts "Looking for recipients"
        {recipients, neighbours} = get_active_neighbours(neighbours, MapSet.new, 0, stop_count, length(neighbours))
        for recipient <- recipients do
            #IO.puts "sending rumor to: #{inspect(recipient)} from: #{inspect(self)}"
            send recipient, {:rumor, self(), message}
        end
        neighbours
    end
    defp get_random_neighbours(neighbours, number \\ 1) do
        recipients = Enum.take_random(neighbours, number)
        # for recipient <- recipients do
        #     if not(Process.alive?(recipient)) do
        #         List.delete(recipients, recipients)
        #     end
        # end
        recipients
    end
    # Following can be used in fault tolerance code
    defp get_active_neighbours(neighbours, act_recipients, size, stop_count, neighbour_count) when size == stop_count do
        #IO.puts "Recipients selected: #{inspect(act_recipients)}"
        {act_recipients, neighbours}
    end
    # No more neighbors to be found
    defp get_active_neighbours(neighbours, act_recipients, size, stop_count, neighbour_count) when neighbours == [] do
        #IO.puts "neighbours exhausted"
        {[], []}
    end
    # stop_count is more than total number of current_neighbors
    # defp get_active_neighbours(neighbours, act_recipients, size, stop_count, neighbour_count) when size == neighbour_count do
    #     {act_recipients, neighbours}
    # end
    defp get_active_neighbours(neighbours, act_recipients, size, stop_count, neighbour_count) do
        neighbour = Enum.random(neighbours)
        #IO.puts "neighbours: #{inspect(neighbours)} act_recipients: #{inspect(act_recipients)}"
        if Process.alive?(neighbour) do
            #IO.puts "Adding to active neighbours: #{inspect(neighbour)}"
            act_recipients = MapSet.put(act_recipients, neighbour)
        else
            #IO.puts "Removing killed process: #{inspect(neighbour)}"
            neighbours = List.delete(neighbours, neighbour)
            neighbour_count = neighbour_count - 1
        end
        size = MapSet.size(act_recipients)
        get_active_neighbours(neighbours, act_recipients, size, stop_count, neighbour_count)
    end
    defp terminate(parent, send_msg_pid \\ 0) do
        send parent, {:terminating, self(), :normal}
        Process.exit(send_msg_pid, :kill)
        #IO.puts "Killing self: #{inspect(self())}"
        Process.exit(self(), :normal)
    end
end
