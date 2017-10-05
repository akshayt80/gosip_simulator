defmodule PushSum do
    def start(parent) do
        neighbours = []
        pid_str = self() |> inspect
        # String.slice(s, 7..-4) slices 141 from #PID<0.141.0> 
        process_number = elem(Integer.parse(String.slice(pid_str, 7..-4)), 0)
        {s, w} = {process_number, 1}
        ratio = 0.0
        ratio_count = 0
        listen(neighbours, {s, w}, ratio, ratio_count, parent)
    end
    defp listen(neighbours, {s, w},ratio, ratio_count, parent, terminated \\ false) do
        #IO.puts "start listening: #{inspect(self())}"
        receive do
            {:neighbours, neighbour_list} -> neighbours = set_neighbours(neighbour_list)
                #IO.inspect neighbours, label: "Registered neighbours"
            {:rumor, from, message} -> {s, w, ratio, ratio_count, terminated, neighbours} = handle_rumors(message, {s, w}, ratio, ratio_count, neighbours, from, parent, terminated)
            {:initiate, value} -> {s, w, ratio, neighbours} = send_rumor({s, w}, neighbours)
        after
            100 -> check_active_neighbours(neighbours, parent)
        end
        listen(neighbours, {s, w}, ratio, ratio_count, parent, terminated)
    end
    defp check_active_neighbours(neighbours, parent) do
        # make sure that the initialization of the node is done
        # as  after initialization it will have non zero neigbours
        if length(neighbours) != 0 do
            {recipients, neighbours} = get_active_neighbours(neighbours, MapSet.new, 0, length(neighbours))
            IO.puts "self: #{inspect(self())} check active neighbours here"
            if neighbours == [] do
                #IO.puts "No active neighbours left: #{inspect(self())}"
                terminate(parent)
            end
        end
    end
    defp set_neighbours(neighbours) do
        List.delete(neighbours, self())
    end
    defp handle_rumors(message, {s, w}, ratio, count, neighbours, from, parent, terminated \\ false, terminate_count \\ 3) do
        {new_s, new_w} = message
        #IO.puts "Received rumor from: #{inspect(from)} to: #{inspect(self())} new_s: #{new_s} new_w: #{new_w} old_s: #{s} old_w: #{w}"
        new_ratio = new_s / new_w
        # handle reduction in ratio
        # if new_ratio > ratio do
        #   change = new_ratio - ratio
        # else
        #   change = ratio - new_ratio 
        # end
        change = new_ratio - ratio
        
        if change > 0.0000000001 do
            s = new_s + s
            w = new_w + w
            count = 0
        else
            count = count + 1
        end
        if count >=  terminate_count or terminated do
            # Last message
            #send_rumor(message, neighbours)
            # TODO:- fix the bug that it keeps on sendung terminate to parent
            if not(terminated) do
                IO.puts "Terminating: #{inspect(self())} with s: #{s} w: #{w}"
                terminate(parent)
                terminated = true
            end
        else
            {s, w, ratio, neighbours} = send_rumor({s, w}, neighbours)
            # send message to self
            {s, w, ratio, neighbours} = send_rumor({s, w}, neighbours, true)
        end
        {s, w, ratio, count, terminated, neighbours}
    end
    defp send_rumor({s, w}, neighbours, self \\ false) do
        s = s / 2
        w = w / 2
        ratio = s / w
        if self do
            recipients = [self()]
        else
            #recipients = get_random_neighbours(neighbours)
            {recipients, neighbours} = get_active_neighbours(neighbours, MapSet.new, 0, length(neighbours))
            IO.puts "self: #{inspect(self())} send rumor here"
        end
        for recipient <- recipients do
            #IO.puts "sending rumor to: #{inspect(recipient)} from: #{inspect(self)} s: #{s} w: #{w}"
            send recipient, {:rumor, self(), {s, w}}
        end
        #send self(), {:rumor, self(), {s, w}}
        {s, w, ratio, neighbours}
    end
    defp get_random_neighbours(neighbours, number \\ 1) do
        Enum.take_random(neighbours, number)
    end
    # Following can be used in fault tolerance code
    defp get_active_neighbours(neighbours, act_recipients, size, neighbour_count) when size == 1 do
        #IO.puts "Recipients selected: #{inspect(act_recipients)}"
        {act_recipients, neighbours}
    end
    # No more neighbors to be found
    defp get_active_neighbours(neighbours, act_recipients, size, neighbour_count) when neighbours == [] do
        #IO.puts "neighbours exhausted"
        {[], []}
    end
    # stop_count is more than total number of current_neighbors
    # defp get_active_neighbours(neighbours, act_recipients, size, stop_count, neighbour_count) when size == neighbour_count do
    #     {act_recipients, neighbours}
    # end
    defp get_active_neighbours(neighbours, act_recipients, size, neighbour_count) do
        neighbour = Enum.random(neighbours)
        IO.puts "self: #{inspect(self())} neighbours: #{inspect(neighbours)} act_recipients: #{inspect(act_recipients)}"
        if Process.alive?(neighbour) do
            IO.puts "Adding to active neighbours: #{inspect(neighbour)}"
            act_recipients = MapSet.put(act_recipients, neighbour)
        else
            IO.puts "Removing killed process: #{inspect(neighbour)} from: #{inspect(self)}"
            neighbours = List.delete(neighbours, neighbour)
            neighbour_count = neighbour_count - 1
            IO.puts "self: #{inspect(self())} neighbours: #{inspect(neighbours)}"
        end
        size = MapSet.size(act_recipients)
        get_active_neighbours(neighbours, act_recipients, size, neighbour_count)
    end
    defp terminate(parent) do
        #IO.puts "Terminating: #{inspect(self())}"
        send parent, {:terminating, self(), :normal}
        Process.exit(self(), :normal)
    end    
end
