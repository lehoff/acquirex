defmodule Acquirex.Corporation do

  @behaviour :gen_fsm

  alias Acquirex.Tiles
  alias Acquirex.Space

  @type t :: Sackson | Zeta | Hydra | Fusion | America | Phoenix | Quantum
  @type size :: 0..108
  @type status :: :inactive | :active | :safe

  @base_tier %{Sackson: 0, Zeta: 0,
               Hydra: 1, Fusion: 1, America: 1,
               Phoenix: 2, Quantum: 2}

  def corporations() do
    [ Sackson, Zeta, Hydra, Fusion, America, Phoenix, Quantum ]
  end

  def corp_name(corp) do
    corp |>
    Atom.to_string |>
    String.to_char_list |> Enum.drop(7) |> String.Chars.to_string
  end

  @spec start_link(t) :: Agent.on_start
  def start_link(t) do
    :gen_fsm.start_link({:local, t}, __MODULE__, [t], [])
  end

  def incorporable?(coord) do
    case Space.move_outcome(coord) do
      Incorporate ->
        statuses = for c <- corporations(), do: {c, status(c)}
        for {c, :inactive} <- statuses, do: c
      _ ->
        []
    end
  end

  def price(t) do
    :gen_fsm.sync_send_all_state_event(t, :price)
  end

  def status(t) do
    :gen_fsm.sync_send_all_state_event(t, :status)
  end

  @spec join(t, Tiles.t) :: :ok
  def join(corp, coord) do
    :gen_fsm.send_event(corp, {:join, coord})
  end



  @spec tier(t, non_neg_integer) :: 1..11
  def tier(c, count) do
    @base_tier[c] + raw_tier(count)
  end

  @spec tier_bonus(1..11) :: {non_neg_integer, non_neg_integer}
  def tier_bonus(tier) do
    majority = majority(tier)
    {majority, div(majority, 2)}
  end

  defp majority(tier), do: (tier+1)*1_000

  defp raw_tier(count) when count <=  6, do: count-1
  defp raw_tier(count) when count <= 10, do: 5
  defp raw_tier(count) when count <= 20, do: 6
  defp raw_tier(count) when count <= 30, do: 7
  defp raw_tier(count) when count <= 40, do: 8
  defp raw_tier(count) when count >= 41, do: 9

  defp tier_price(tier) do
    div(majority(tier), 10)
  end

  def init(t) do
    {:ok, :inactive, %{name: t, members: []}}
  end


  def inactive({:join, coord}, s) do
    {:next_state, :active, %{s | members: [coord|s.members]}}
  end

  def active({:join, coord}, s) do
    s = %{s | members: [coord|s.members]}
    next_state = if length(s.members)>10 do :safe else :active end
    {:next_state, next_state, s}
  end

  def safe({:join, coord}, s ) do
    {:next_state, :safe, %{s | members: [coord|s.members]}}
  end

  
  def handle_info(_, _state_name, s) do
    {:stop, :unexpected_message, s}
  end

  def handle_sync_event(:status, _from, state_name, s) do
    reply = state_name
    {:reply, reply, state_name, s}
  end

  def handle_sync_event(:price, _from, state_name, s) do
    price = tier(s.name, length s.members) |> tier_price
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
