defmodule PushSum1 do
    def start(parent) do
        pid_str = self() |> inspect
        # String.slice(s, 7..-4) slices 141 from #PID<0.141.0> 
        process_number = elem(Integer.parse(String.slice(pid_str, 7..-4)), 0)
        listen([], {process_number, 1}, 0.0, 0, parent, 0)
    end
    defp listen(neighbors, {s, w},ratio, ratio_count, parent, neighbor_count, terminated \\ false) do
        #IO.puts "start listening: #{inspect(self())}"
        receive do
            {:neighbours, neighbor_list} -> {neighbors, neighbor_count} = set_neighbors(neighbor_list)
                #IO.inspect neighbors, label: "Registered neighbors"
            {:rumor, from, message} -> {s, w, ratio, ratio_count, terminated, neighbors, neighbor_count} = handle_rumors(message, {s, w}, ratio, ratio_count, neighbors, from, parent, neighbor_count, terminated)
            {:initiate, _} -> {s, w, ratio, neighbors, neighbor_count} = send_rumor({s, w}, neighbors, neighbor_count)
        after
            900 -> {neighbors, neighbor_count} = check_active_neighbors(neighbors, parent, neighbor_count)
        end
        listen(neighbors, {s, w}, ratio, ratio_count, parent, neighbor_count, terminated)
    end
    defp check_active_neighbors(neighbors, parent, neighbor_count) do
        # make sure that the initialization of the node is done
        # as  after initialization it will have non zero neighbors
        if neighbor_count != 0 do
            {_, neighbors, neighbor_count} = get_active_neighbors(neighbors, MapSet.new, 0, neighbor_count)
            IO.puts "self: #{inspect(self())} check active neighbors here"
            if neighbors == [] do
                #IO.puts "No active neighbors left: #{inspect(self())}"
                terminate(parent)
            end
        end
        {neighbors, neighbor_count}
    end
    defp set_neighbors(neighbors) do
        neighbors = List.delete(neighbors, self())
        neighbor_count = length(neighbors)
        {neighbors, neighbor_count}
    end
    defp handle_rumors({new_s, new_w}, {s, w}, old_ratio, count, neighbors, from, parent, neighbor_count, terminated \\ false, terminate_count \\ 2) do
        #IO.puts "Received rumor from: #{inspect(from)} to: #{inspect(self())} new_s: #{new_s} new_w: #{new_w} old_s: #{s} old_w: #{w}"
        if from != self() do
            new_ratio = (new_s + (s/2)) / (new_w + (w/2))
            change = new_ratio - old_ratio
        end
        
        if from != self() and abs(change) > 0.0000000001 do
            # terminated if condition introduced
            if not(terminated) do
                s = new_s + s
                w = new_w + w
                # resetting count value
                count = 0
            end
        else
            count = count + 1
        end
        if count >=  terminate_count or terminated or neighbor_count == 0 do
            if not(terminated) or neighbor_count == 0 do
                #{s, w, ratio, neighbors, neighbor_count} = send_rumor({s, w}, neighbors, neighbor_count)
                #IO.puts "Terminating: #{inspect(self())} with s: #{s} w: #{w}"
                terminate(parent)
                terminated = true
            end
        else
            #IO.puts "before sending to random neighbor self: #{inspect(self())} s: #{s} w: #{w}"
            {s, w, _, neighbors, neighbor_count} = send_rumor({s, w}, neighbors, neighbor_count)
            # send message to self for better convergence as described algorithm in paper:
            # http://www.comp.nus.edu.sg/~ooibc/courses/cs6203/focs2003-gossip.pdf
            #IO.puts "before sending to self: #{inspect(self())} s: #{s} w: #{w}"
            {_, _, _, neighbors, neighbor_count} = send_rumor({s, w}, neighbors, neighbor_count, true)
        end
        ratio = s / w
        #IO.puts "after sending to the nodes self: #{inspect(self())} s: #{s} w: #{w}"
        {s, w, ratio, count, terminated, neighbors, neighbor_count}
    end
    # terminated added terminated and {new_s, new_w}
    defp send_rumor({s, w}, neighbors, neighbor_count, self \\ false) do
        s = s / 2
        w = w / 2
        #IO.puts "self: #{inspect(self())} s: #{s} w: #{w}"
        ratio = s / w
        if self do
            recipients = [self()]
        else
            #recipients = get_random_neighbors(neighbors)
            {recipients, neighbors, neighbor_count} = get_active_neighbors(neighbors, MapSet.new, 0, neighbor_count)
            #IO.puts "self: #{inspect(self())} send rumor here"
        end
        for recipient <- recipients do
            send recipient, {:rumor, self(), {s, w}}
        end
        #send self(), {:rumor, self(), {s, w}}
        {s, w, ratio, neighbors, neighbor_count}
    end
    defp get_random_neighbors(neighbors, number \\ 1) do
        Enum.take_random(neighbors, number)
    end
    # Following can be used in fault tolerance code
    defp get_active_neighbors(neighbors, act_recipients, size, neighbor_count) when size == 1 do
        #IO.puts "Recipients selected: #{inspect(act_recipients)}"
        {act_recipients, neighbors, neighbor_count}
    end
    # No more neighbors to be found
    defp get_active_neighbors(neighbors, act_recipients, size, neighbor_count) when neighbors == [] do
        #IO.puts "neighbors exhausted"
        {neighbors, act_recipients, neighbor_count}
    end
    # stop_count is more than total number of current_neighbors
    # defp get_active_neighbors(neighbors, act_recipients, size, stop_count, neighbor_count) when size == neighbor_count do
    #     {act_recipients, neighbors}
    # end
    defp get_active_neighbors(neighbors, act_recipients, size, neighbor_count) do
        #IO.puts "self: #{inspect(self())} neighbor_count: #{neighbor_count} neighbors: #{inspect(neighbors)}"
        neighbor = Enum.random(neighbors)
        #IO.puts "self: #{inspect(self())} neighbors: #{inspect(neighbors)} act_recipients: #{inspect(act_recipients)}"
        if Process.alive?(neighbor) do
            #IO.puts "Adding to active neighbors: #{inspect(neighbor)}"
            act_recipients = MapSet.put(act_recipients, neighbor)
            size = size + 1
        else
            #IO.puts "Removing killed process: #{inspect(neighbor)} from: #{inspect(self)}"
            neighbors = List.delete(neighbors, neighbor)
            neighbor_count = neighbor_count - 1
            #IO.puts "self: #{inspect(self())} left neighbors: #{inspect(neighbors)}"
        end
        get_active_neighbors(neighbors, act_recipients, size, neighbor_count)
    end
    defp terminate(parent) do
        IO.puts "Terminating: #{inspect(self())}"
        send parent, {:terminating, self(), :normal}
        Process.exit(self(), :normal)
    end    
end
