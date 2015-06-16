defmodule Acquirex.Player.Portfolio do

  
  def start_link(player) do
    Agent.start_link(&initial_stocks/0, name: via_name(player))
  end

  def add(player, corp, count \\ 1) do
    Agent.cast(via_name(player), fn s -> %{s| corp: s[corp]+count} end)
  end

  def count(player, corp) do
    Agent.get(via_name(player), fn s -> s[corp] end)
  end

  def delete(player, corp, count) do
    Agent.cast(via_name(player), fn s -> %{s | corp: s[corp] - count} end)
  end


  defp initial_stocks() do
    Enum.into(for c <- Acquirex.Corporation.corporations() do {c,0} end, %{})
  end

  defp via_name(player) do
    {:via, :gproc, portfolio_name(player)}
  end

  defp portfolio_name(player) do
    {:n, :l, {__MODULE__, player}}
  end
end
