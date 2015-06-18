defmodule Acquirex.Turn do
  @behaviour :gen_fsm

  alias Acquirex.Space
  alias Acquirex.Player
  alias Acquirex.Corporation
  alias Acquirex.Bank
 
  def start_link() do
    :gen_fsm.start_link({:local, __MODULE__}, __MODULE__, :no_args, [])        
  end



  def move(player, tile) do
    :gen_fsm.send_event(__MODULE__, {:move, player, tile})
  end

  def inc_choice(player, corp) do
    :gen_fsm.send_event(__MODULE__, {:inc_choice, player, corp})
  end

  def buy_choice(player, corps) when length(corps)<=3 do
    :gen_fsm.send_event(__MODULE__, {:buy_choice, player, corps})
  end

  # states
  def idle({:move, player, tile}, nil) do
    case Space.move_outcome(tile) do
      Nothing ->
        buy_stocks(player)
      Incorporate ->
        case Corporation.incorporable?(tile) do
          [] ->
            buy_stocks(player)
          corps ->
            Player.info(player, {:choose_corporation, corps})
            {:next_state, :await_incorporation_choice, %{player: player, tile: tile, corps: corps}}
        end
    end
  end
  
  def await_incorporation_choice({:inc_choice, player, corp}, %{player: player}=s) do
    if corp in s.corps do
      Space.join(s.tile, corp)
      founder_stock = Bank.founders_stock(player, corp)
      Player.info(player, {:founder, corp, founder_stock})
      buy_stocks(player)
    else
      Player.info({:incorrect_corp_choice, corp, s.corps})
      {:next_state, :await_incorporation_choice, s}
    end
  end

  defp buy_stocks(player) do
    Player.info(player, :buy_stock) # @todo: should send a list of active corporations
    {:next_state, :await_buy_choice, %{player: player}}
  end

  def await_buy_choice({:buy_choice, player, corps}, %{player: player}=s) do
    buy_results = for c <- corps, do: Bank.buy(player, c)
    Player.info({:buy_results, buy_results})
  end

  ## gen_fsm callbacks
  def init(:no_args) do
    {:ok, :idle, nil}
  end

  def handle_info(_, _state_name, s) do
    {:stop, :unexpected_message, s}
  end

  def handle_sync_event(:status, _from, state_name, s) do
    reply = state_name
    {:reply, reply, state_name, s}
  end

  def handle_event(_, _state_Name, s) do
    {:stop, :unexecpted_event, s}
  end

  def terminate(_reason, _state_name, _s) do
    :ok
  end

  def code_change(_old_vsn, state_name, s, _extra) do
    {:ok, state_name, s}
  end

end
