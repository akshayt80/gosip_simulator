defmodule Gossip do
    def start(parent) do
        neighbours = []
        rumor_count = 0
        listen(neighbours, rumor_count, parent)
    end
    defp listen(neighbours, rumor_count, parent) do
        receive do
            {:neighbours, neighbour_list} -> neighbours = set_neighbours(neighbour_list)
                IO.inspect neighbours, label: "Registered neighbours"
            {:rumor, from, message} -> rumor_count = handle_rumors(message, rumor_count, neighbours, from, parent)
            {:initiate, value} -> send_rumor("secret message", neighbours)
        end
        listen(neighbours, rumor_count, parent)
    end
    defp set_neighbours(neighbours) do
        List.delete(neighbours, self())
    end
    defp handle_rumors(message, count, neighbours, from, parent, terminate_count \\ 3) do
        IO.inspect from, label: "Received rumor from"
        count = count + 1
        if count >=  terminate_count do
            terminate(parent)
        else
            send_rumor(message, neighbours)
        end
        count
    end
    defp send_rumor(message, neighbours) do
        recipients = get_random_neighbours(neighbours)
        for recipient <- recipients do
            IO.inspect recipient, label: "sending rumor to"
            send recipient, {:rumor, self(), message}
        end
    end
    defp get_random_neighbours(neighbours, number \\ 1) do
        Enum.take_random(neighbours, number)
    end
    defp terminate(parent) do
        send parent, {:terminating, self(), :normal}
    end
end
