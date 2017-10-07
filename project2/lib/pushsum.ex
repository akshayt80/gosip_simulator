defmodule PushSum do
    def start(parent) do
        neighbours = []
        pid_str = self() |> inspect
        # String.slice(s, 7..-4) slices 141 from #PID<0.141.0> 
        process_number = elem(Integer.parse(String.slice(pid_str, 7..-4)), 0)
        {s, w} = {process_number, 1}
        ratio = 0.0
        ratio_count = 0
        neighbour_count = 0
        listen(neighbours, {s, w}, ratio, ratio_count, parent, neighbour_count)
    end
    defp listen(neighbours, {s, w},ratio, ratio_count, parent, neighbour_count, terminated \\ false) do
        #IO.puts "start listening: #{inspect(self())}"
        receive do
            {:neighbours, neighbour_list} -> {neighbours, neighbour_count} = set_neighbours(neighbour_list)
                #IO.inspect neighbours, label: "Registered neighbours"
            {:rumor, from, message} -> {s, w, ratio, ratio_count, terminated, neighbours, neighbour_count} = handle_rumors(message, {s, w}, ratio, ratio_count, neighbours, from, parent, neighbour_count, terminated)
            {:initiate, value} -> {s, w, ratio, neighbours, neighbour_count} = send_rumor({s, w}, neighbours, neighbour_count)
        after
            100 -> {neighbours, neighbour_count} = check_active_neighbours(neighbours, parent, neighbour_count)
        end
        listen(neighbours, {s, w}, ratio, ratio_count, parent, neighbour_count, terminated)
    end
    defp check_active_neighbours(neighbours, parent, neighbour_count) do
        # make sure that the initialization of the node is done
        # as  after initialization it will have non zero neigbours
        if neighbour_count != 0 do
            {recipients, neighbours, neighbour_count} = get_active_neighbours(neighbours, MapSet.new, 0, neighbour_count)
            IO.puts "self: #{inspect(self())} check active neighbours here"
            if neighbours == [] do
                #IO.puts "No active neighbours left: #{inspect(self())}"
                terminate(parent)
            end
        end
        {neighbours, neighbour_count}
    end
    defp set_neighbours(neighbors) do
        neighbors = List.delete(neighbors, self())
        neighbour_count = length(neighbors)
        {neighbors, neighbour_count}
    end
    defp handle_rumors({new_s, new_w}, {s, w}, old_ratio, count, neighbours, from, parent, neighbour_count, terminated \\ false, terminate_count \\ 3) do
        #IO.puts "Received rumor from: #{inspect(from)} to: #{inspect(self())} new_s: #{new_s} new_w: #{new_w} old_s: #{s} old_w: #{w}"
        new_ratio = (new_s + s) / (new_w + w)
        #IO.puts "New ratio: #{new_ratio}"
        # handle reduction in ratio
        # if new_ratio > ratio do
        #   change = new_ratio - ratio
        # else
        #   change = ratio - new_ratio 
        # end
        change = new_ratio - old_ratio
        
        # terminated removed and condition
        if abs(change) > 0.0000000001 and from != self() do
            # terminated if condition introduced
            if not(terminated) do
                s = new_s + s
                w = new_w + w
                # resetting count value
                count = 0
            end
        else
            # increasing count as ratio change was not significant
            #if from != self() do
            count = count + 1
            #end
        end
        if count >=  terminate_count or terminated do
            # Last message
            #send_rumor(message, neighbours)
            # TODO:- fix the bug that it keeps on sendung terminate to parent
            if not(terminated) do
                #{s, w, ratio, neighbours, neighbour_count} = send_rumor({s, w}, neighbours, neighbour_count)
                IO.puts "Terminating: #{inspect(self())} with s: #{s} w: #{w}"
                terminate(parent)
                terminated = true
            else
                # terminated uncommented
                {s, w, ratio, neighbours, neighbour_count} = send_rumor({s, w}, neighbours, neighbour_count, false, true, {new_s, new_w})
            end
        else
            #IO.puts "Sending to random node from: #{inspect(self())} s: #{s} w: #{w} ratio: #{old_ratio}"
            {s, w, old_ratio, neighbours, neighbour_count} = send_rumor({s, w}, neighbours, neighbour_count)
            # send message to self for better convergence as described algorithm in paper:
            # http://www.comp.nus.edu.sg/~ooibc/courses/cs6203/focs2003-gossip.pdf
            #IO.puts "Sending to self: #{inspect(self())} s: #{s} w: #{w} ratio: #{old_ratio}"
            {s, w, old_ratio, neighbours, neighbour_count} = send_rumor({s, w}, neighbours, neighbour_count, true)
            #IO.puts "After sending self: #{inspect(self())} s: #{s} w: #{w} ratio: #{old_ratio}"
            #count = count + 1
        end
        {s, w, old_ratio, count, terminated, neighbours, neighbour_count}
    end
    # terminated added terminated and {new_s, new_w}
    defp send_rumor({s, w}, neighbours, neighbour_count, self \\ false, terminated \\ false, {new_s, new_w} \\ {0, 0}) do
        # terminated if condition introduced
        if not(terminated) do
            s = s / 2
            w = w / 2 
        end
        #IO.puts "self: #{inspect(self())} s: #{s} w: #{w}"
        ratio = s / w
        if self do
            recipients = [self()]
        else
            #recipients = get_random_neighbours(neighbours)
            {recipients, neighbours, neighbour_count} = get_active_neighbours(neighbours, MapSet.new, 0, neighbour_count)
            #IO.puts "self: #{inspect(self())} send rumor here"
        end
        for recipient <- recipients do
            #IO.puts "sending rumor to: #{inspect(recipient)} from: #{inspect(self())} s: #{s} w: #{w}"
            if not(recipient == self()) do
                IO.puts "sending rumor to: #{inspect(recipient)} from: #{inspect(self())} s: #{s} w: #{w} ratio: #{ratio}"
            end
            # trminated new send introduced
            if terminated do
              send recipient, {:rumor, self(), {new_s, new_w}}
            else
              send recipient, {:rumor, self(), {s, w}}
            end
        end
        #send self(), {:rumor, self(), {s, w}}
        {s, w, ratio, neighbours, neighbour_count}
    end
    defp get_random_neighbours(neighbours, number \\ 1) do
        Enum.take_random(neighbours, number)
    end
    # Following can be used in fault tolerance code
    defp get_active_neighbours(neighbours, act_recipients, size, neighbour_count) when size == 1 do
        #IO.puts "Recipients selected: #{inspect(act_recipients)}"
        {act_recipients, neighbours, neighbour_count}
    end
    # No more neighbors to be found
    defp get_active_neighbours(neighbours, act_recipients, size, neighbour_count) when neighbours == [] do
        #IO.puts "neighbours exhausted"
        {[], [], 0}
    end
    # stop_count is more than total number of current_neighbors
    # defp get_active_neighbours(neighbours, act_recipients, size, stop_count, neighbour_count) when size == neighbour_count do
    #     {act_recipients, neighbours}
    # end
    defp get_active_neighbours(neighbours, act_recipients, size, neighbour_count) do
        IO.puts "here"
        neighbour = Enum.random(neighbours)
        #IO.puts "self: #{inspect(self())} neighbours: #{inspect(neighbours)} act_recipients: #{inspect(act_recipients)}"
        if Process.alive?(neighbour) do
            #IO.puts "Adding to active neighbours: #{inspect(neighbour)}"
            act_recipients = MapSet.put(act_recipients, neighbour)
        else
            #IO.puts "Removing killed process: #{inspect(neighbour)} from: #{inspect(self)}"
            neighbours = List.delete(neighbours, neighbour)
            neighbour_count = neighbour_count - 1
            #IO.puts "self: #{inspect(self())} left neighbours: #{inspect(neighbours)}"
        end
        size = MapSet.size(act_recipients)
        get_active_neighbours(neighbours, act_recipients, size, neighbour_count)
    end
    defp terminate(parent) do
        #IO.puts "Terminating: #{inspect(self())}"
        send parent, {:terminating, self(), :normal}
        #Process.exit(self(), :normal)
    end    
end
