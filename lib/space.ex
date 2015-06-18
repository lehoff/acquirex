defmodule Acquirex.Space do

  alias Acquirex.Corporation
  @type status :: Empty | Full | {Incorporated, Corporation.t}

  def start_link(coord) do
    Agent.start_link(fn -> Empty end, name: {:via, :gproc, space_name(coord)})
  end

  def status(coord) do
    Agent.get({:via, :gproc, space_name(coord)}, fn s -> s end)
  end

  @spec move_outcome(Tiles.t) :: Nothing | Incorporate | {Merger, [Corporation.t]}
  def move_outcome(coord) do
    ns = neighbours(coord)
    n_status = for n <- ns, do: status(n)
    case Enum.sort(n_status) do
      [_, _, _, Full] ->
        Incorporate
      [_, _, {Incorporated, _}, {Incorporated,_}] ->
        corps = for {Incorporated, c} <- n_status, do: c
        {Merger, corps}
      _ ->
        Nothing
    end
  end

  
  def fill(coord) do
    Agent.cast({:via, :gproc, space_name(coord)}, fn Empty -> Full end)
  end

  def incorporate(coord, corp) do
    Agent.cast({:via, :gproc, space_name(coord)}, fn _s -> handle_incorporate(coord, corp) end)
  end

  def join(coord, corp) do
    Agent.cast({:via, :gproc, space_name(coord)}, fn s -> handle_join(s, coord, corp) end)
  end

  defp handle_incorporate(coord, corp) do
    ns = neighbours(coord)
    for n <- ns, do: join(n, corp)
    Corporation.join(corp, coord)
    {Incorporated, corp}
  end

  defp handle_join(Full, coord, corp) do
    ns = neighbours(coord)
    for n <- ns, do: join(n, corp)
    Corporation.join(corp, coord)
    {Incorporated, corp}
  end

  defp handle_join(s, _, _), do: s

  defp space_name(coord) do
    {:n, :l, {__MODULE__, coord}}
  end

  defp neighbours({1,'a'}),  do: [{1,'b'}, {2,'b'}]
  defp neighbours({1,'i'}),  do: [{1,'h'}, {2,'i'}]
  defp neighbours({12,'a'}), do: [{11,'a'}, {12,'b'}]
  defp neighbours({12,'i'}), do: [{11,'i'}, {12,'h'}]
  defp neighbours({1,row}),  do: [{1, row_above row},
                                  {1, row_below row},
                                  {2, row}]
  defp neighbours({12,row}), do: [{12, row_above row},
                                  {12, row_below row},
                                  {11, row}]
  defp neighbours({column,'a'}), do: [{column-1,'a'},
                                      {column+1,'a'},
                                      {column,'b'}]
  defp neighbours({column,'i'}), do: [{column-1,'i'},
                                      {column+1,'i'},
                                      {column,'h'}]
  defp neighbours({column, row}), do: [{column-1, row},
                                       {column+1, row},
                                       {column, row_above row},
                                       {column, row_below row}]

  defp row_above([row]), do: [row-1]

  defp row_below([row]), do: [row+1]
  
end
