defmodule 2DGrid do


  def build({topology, pop, k}) do
    case topology do 
      :perfect_grid -> index_map = pop
                                    |> Enum.with_index
                                    |> Enum.map(fn({a,b}) -> {b,a} end
                                    |> Map.new
                       0..k-1
                         |> Enum.map(fn(i) -> get_neighbours(i, k) end)
                         |> Enum.map(fn(l) -> Enum.map(l, fn(e) -> index_map[e] end) end)
    
      
    end
  end

  defp coord_to_index({x,y},kd) do
    x+kd*y
  end
  
  defp index_to_coord(i,kd) do
     {rem(i, kd), div(i, kd)}
  end
  
  defp pair_neighbours(l) do
    Enum.zip([[]] ++ l, Enum.reverse(l) ++ [[]])
  end
  
  defp get_neighbours(i, k) do
    kd = round(:math.sqrt(k))
    {x,y} = index_to_coord(i, kd)
    [{x-1,y},{x+1,y},{x,y-1},{x,y+1}]
      |> Enum.filter(fn({x,y}) -> (Enum.member? 0..kd-1, x) && (Enum.member? 0..kd-1, y) end)
      |> Enum.map(fn(x) -> coord_to_index(x,kd) end)
  end

  defp participant({max_count, neighbours}) do
    receive do
      {:neighbours, n_list} -> st = {max_count, n_list}
      {:rumor} -> st = {max_count-1, neighbours}
                  send(Enum.random(neighbours), {:rumor})
    end
    participant(st)
  end
end