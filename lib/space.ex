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
    case neighbour_status(coord) do
      [_, _, _, Full] ->
        Incorporate
      [_, _, {Incorporated, _}, {Incorporated,_}] = ns ->
        corps = (for {Incorporated, c} <- ns, do: c) |> Enum.uniq
        {Merger, corps}
      _ ->
        Nothing
    end
  end

  def neighbour_status(coord) do
    (for n <- neighbours(coord), do: status(n))
    |> Enum.sort
  end
  
  def fill(coord) do
    Agent.cast({:via, :gproc, space_name(coord)}, fn _s -> handle_fill(coord) end)
  end

  def incorporate(coord, corp) do
    Agent.cast({:via, :gproc, space_name(coord)}, fn _s -> handle_incorporate(coord, corp) end)
  end

  def join(coord, corp) do
    Agent.cast({:via, :gproc, space_name(coord)}, fn s -> handle_join(s, coord, corp) end)
  end

  # fill will only happen if the move outcome is Nothing
  # could consider having a Join outcome at some point
  defp handle_fill(coord) do
    case neighbour_status(coord) do
      [_, _, _, {Incorporated, c}] ->
        for n <- neighbours(coord), do: join(n, c)
        Corporation.join(c, coord)
        {Incorporated, c}
      _ ->
        Full
    end
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

  def neighbours({column, [c]=row}) when column in 1..12 and c in ?a..?i do
    [{column-1, row},
     {column+1, row},
     {column, row_above row},
     {column, row_below row}]
  end
  def neighbours({_,_}), do: []

  defp row_above([row]), do: [row-1]

  defp row_below([row]), do: [row+1]
  
end
