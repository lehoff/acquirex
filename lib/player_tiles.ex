defmodule Acquirex.Player.Tiles do

  
  def start_link(player) do
    Agent.start_link(fn -> [] end, name: via_name(player))
  end

  def count(player) do
    Agent.get(via_name(player), fn s -> length s end)
  end

  def tiles(player) do
    Agent.get(via_name(player), &(&1))
  end

  def add(player, tile) do
    Agent.cast(via_name(player), &([tile|&1]))
  end

  def remove(player, tile) do
    Agent.cast(via_name(player), &(List.delete(&1, tile)))
  end

  defp via_name(player) do
    {:via, :gproc, tiles_name(player)}
  end

  defp tiles_name(player) do
    {:n, :l, {__MODULE__, player}}
  end
end
