defmodule Gossip do
    def start(parent) do
        neighbours = []
        rumor_count = 0
        listen(neighbours, rumor_count, parent)
    end
    defp listen(neighbours, rumor_count, parent, terminated \\ false) do
        #IO.puts "start listening: #{inspect(self())}"
        receive do
            {:neighbours, neighbour_list} -> neighbours = set_neighbours(neighbour_list)
                IO.inspect neighbours, label: "Registered neighbours"
            {:rumor, from, message} -> {rumor_count, neighbours, terminated} = handle_rumors(message, rumor_count, neighbours, from, parent, terminated)
            {:initiate, value} -> send_rumor("secret message", neighbours)
        end
        listen(neighbours, rumor_count, parent, terminated)
    end
    defp set_neighbours(neighbours) do
        List.delete(neighbours, self())
    end
    defp handle_rumors(message, count, neighbours, from, parent, terminated \\ false, terminate_count \\ 10) do
        #IO.puts "Received rumor from: #{inspect(from)} to: #{inspect(self())}"
        count = count + 1
        if count >=  terminate_count or terminated do
            # Last message
            send_rumor(message, neighbours)
            terminate(parent)
            terminated = true
        else
            send_rumor(message, neighbours)
            # if neighbours == [] do
            #     terminate(parent)
            # end
        end
        {count, neighbours, terminated}
    end
    defp send_rumor(message, neighbours) do
        # Testing to not kill nodes after n
        recipients = get_random_neighbours(neighbours)
        #TODO:- active recipient always goes through all the neigbours to select an active one
        #IO.puts "Looking for recipients"
        #{recipients, neighbours} = get_active_neighbours(neighbours, MapSet.new, 0)
        for recipient <- recipients do
            #IO.puts "sending rumor to: #{inspect(recipient)} from: #{inspect(self)}"
            send recipient, {:rumor, self(), message}
        end
        neighbours
    end
    defp get_random_neighbours(neighbours, number \\ 10) do
        recipients = Enum.take_random(neighbours, number)
        # for recipient <- recipients do
        #     if not(Process.alive?(recipient)) do
        #         List.delete(recipients, recipients)
        #     end
        # end
        recipients
    end
    defp get_active_neighbours(neighbours, act_recipients, size) when size == 10 do
        #IO.puts "Recipients selected: #{inspect(act_recipients)}"
        {act_recipients, neighbours}
    end
    defp get_active_neighbours(neighbours, act_recipients, size) when neighbours == [] do
        #IO.puts "neighbours exhausted"
        {[], []}
    end
    defp get_active_neighbours(neighbours, act_recipients, size) do
        neighbour = Enum.random(neighbours)
        if Process.alive?(neighbour) do
            act_recipients = MapSet.put(act_recipients, neighbour)
        else
            neighbours = List.delete(neighbours, neighbour)
        end
        size = MapSet.size(act_recipients)
        get_active_neighbours(neighbours, act_recipients, size)
    end
    defp terminate(parent) do
        send parent, {:terminating, self(), :normal}
        #IO.puts "Killing self: #{inspect(self())}"
        #Process.exit(self(), :normal)
    end
end
