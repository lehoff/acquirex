defmodule Acquirex.Player.Portfolio do

  
  def start_link(player) do
    Agent.start_link(&initial_stocks/0, name: via_name(player))
  end

  def add(player, corp, count \\ 1) do
    #    Agent.cast(via_name(player), fn s -> %{s| corp: s[corp]+count} end)
    Agent.cast(via_name(player), fn s -> Dict.put(s, corp, s[corp]+count) end)
  end

  def count(player, corp) do
    Agent.get(via_name(player), fn s -> s[corp] end)
  end

  def counts(player) do
    Agent.get(via_name(player), &(&1))
  end

  def delete(player, corp, count) do
    #    Agent.cast(via_name(player), fn s -> %{s | corp: s[corp] - count} end)
    Agent.cast(via_name(player), fn s -> Dict.put(s, corp, s[corp] - count) end)
  end


  defp initial_stocks() do
    Enum.into(for c <- Acquirex.Corporation.corporations() do {c,0} end, %{})
  end

  def to_string(player) do
    counts(player) |>
      Dict.to_list |>
      Enum.map(fn{corp,count} -> Acquirex.Corporation.corp_name(corp) <> ": " <> Integer.to_string(count) end) |>
      Enum.join ", "
  end

  defp via_name(player) do
    {:via, :gproc, portfolio_name(player)}
  end

  defp portfolio_name(player) do
    {:n, :l, {__MODULE__, player}}
  end
end
