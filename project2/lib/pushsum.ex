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
            {:rumor, from, message} -> {s, w, ratio, ratio_count, terminated} = handle_rumors(message, {s, w}, ratio, ratio_count, neighbours, from, parent, terminated)
            {:initiate, value} -> {s, w, ratio} = send_rumor({s, w}, neighbours)
        end
        listen(neighbours, {s, w}, ratio, ratio_count, parent, terminated)
    end
    defp set_neighbours(neighbours) do
        List.delete(neighbours, self())
    end
    defp handle_rumors(message, {s, w}, ratio, count, neighbours, from, parent, terminated \\ false, terminate_count \\ 3) do
        #IO.puts "Received rumor from: #{inspect(from)} to: #{inspect(self())}"
        {new_s, new_w} = message
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
        else
            count = count + 1
        end
        if count >=  terminate_count or terminated do
            # Last message
            #send_rumor(message, neighbours)
            # TODO:- fix the bug that it keeps on sendung terminate to parent
            terminate(parent)
            terminated = true
        else
            {s, w, ratio} = send_rumor({s, w}, neighbours)
        end
        {s, w, ratio, count, terminated}
    end
    defp send_rumor(message, neighbours) do
        {s, w} = message
        s = s / 2
        w = w / 2
        ratio = s / w
        recipients = get_random_neighbours(neighbours)
        for recipient <- recipients do
            #IO.puts "sending rumor to: #{inspect(recipient)} from: #{inspect(self)}"
            send recipient, {:rumor, self(), {s, w}}
        end
        {s, w, ratio}
    end
    defp get_random_neighbours(neighbours, number \\ 10) do
        Enum.take_random(neighbours, number)
    end
    defp terminate(parent) do
        #IO.puts "Terminating: #{inspect(self())}"
        send parent, {:terminating, self(), :normal}
    end    
end
