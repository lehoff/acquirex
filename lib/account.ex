defmodule Acquirex.Player.Account do

  @start_cash 6_000

  def start_link(player) do
    Agent.start_link(fn -> @start_cash end, name: via_name(player))
  end

  def balance(player) do
    Agent.get(via_name(player), fn s -> s end)
  end
  
  def debit(player, amount) do
    Agent.get_and_update(via_name(player), fn s -> handle_debit(s, amount) end)
  end

  def credit(player, amount) when is_integer(amount) and amount>0 do
    Agent.cast(via_name(player), fn s -> s+amount end)
  end

  defp handle_debit(s, amount) when s>=amount do
    {:ok, s-amount}
  end

  defp handle_debit(s, _) do
    {:error, s}
  end

  defp via_name(player) do
    {:via, :gproc, account_name(player)}
  end

  defp account_name(player) do
    {:n, :l, {__MODULE__, player}}
  end
end
