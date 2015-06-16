defmodule Acquirex.Bank do

  alias Acquirex.Player.Account
  alias Acquirex.Player.Portfolio
  alias Acquirex.Corporation, as: Corp

  def start_link() do
    Agent.start_link(&initial_state/0, name: __MODULE__)
  end

  def buy(player, corp) do
    Agent.get_and_update(__MODULE__, fn s -> handle_buy(s, player, corp) end)
  end

  defp initial_state() do
    Enum.into(for c <- Acquirex.Corporation.corporations() do {c, 25} end,
              %{})
  end

  def trade(player, defunct_corp, corp, count) when rem(count,2)==0 do
    Agent.get_and_update(__MODULE__, fn s -> handle_trade(s, player, defunct_corp, corp, count) end)
  end

  def trade(_, _, _, _) do
    :incorrect_trade_count
  end

  def sell(player, corp, count) do
    Agent.get_and_update(__MODULE__, fn s -> handle_sell(s, player, corp, count) end)
  end

  def counts() do
    Agent.get(__MODULE__, fn s -> s end)
  end

  def print() do
    IO.write "Bank:"
    IO.inspect(counts())
  end

  defp handle_buy(s, player, corp) do
    case s[corp] do
      0 -> {:no_stocks_left, s}
      n ->
        price = Corp.price(corp)
        case Account.debit(player, price) do
          :ok ->
            Portfolio.add(player, corp)
            {{:ok, price}, %{s | corp: n-1}}
           :error ->
            {{:error, corp}, s}
        end
    end
  end

  defp handle_trade(s, player, defunct_corp, corp, count) do
    new_stocks = div(count,2)
    Portfolio.add(player, corp, new_stocks)
    {{:ok, new_stocks},
     %{s| defunct_corp: s[defunct_corp]+count,
       corp: s[corp] - new_stocks}}
  end

  defp handle_sell(s, player, corp, count) do
    price = Corp.price(corp)
    amount = count * price
    Account.credit(player, amount)
    Portfolio.delete(player, corp, count)
    {:ok, %{s| corp: s[corp]+count}}
  end
end
 
