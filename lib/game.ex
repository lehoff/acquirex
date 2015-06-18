defmodule Acquirex.Game do
  @behaviour :gen_fsm

  alias Acquirex.Tiles
  alias Acquirex.Space

  def start_link() do
    :gen_fsm.start_link({:local, __MODULE__}, __MODULE__, :no_args, [])
  end


  def init(:no_args) do
    {:ok, :setup, %{players: []}}
  end

  def join(player) do
    :gen_fsm.send_event(__MODULE__, {:join, player})
  end

  def begin() do
    :gen_fsm.send_event(__MODULE__, :begin)
  end

  def players() do
    :gen_fsm.sync_send_all_state_event(__MODULE__, :players) 
  end

  def current_order() do
    :gen_fsm.sync_send_event(__MODULE__, :current_order)
  end

  def next_turn() do
    :gen_fsm.send_event(__MODULE__, :next)
  end

  def finish() do
    :gen_fsm.send_event(__MODULE__, :finish)
  end

  def status() do
    :gen_fsm.sync_send_all_state_event(__MODULE__, :status)
  end

  def setup({:join, player}, s) do
    {:next_state, :setup, %{s | players: s.players ++ [player]}}
  end

  def setup(:begin, s) do
    initial_tiles = for p <- s.players, do: {p, Acquirex.Tiles.draw}
    [{first,_}|_] = sort_initial(initial_tiles)
    for {_,t} <- initial_tiles, do: Acquirex.Space.fill(t)
    for p <- s.players do
      for _ <- 1..6 do
        Acquirex.Player.Tiles.add(p, Acquirex.Tiles.draw)
      end
    end
    {:next_state, :ongoing, %{s| players: rotate_until(first, s.players)}}
  end

  def print_board() do
    print_column_header
    print_rows
    print_column_header
    print_current_order
  end

  def print() do
    print_board
    Acquirex.Bank.print
    for c <- Acquirex.Corporation.corporations, do: Acquirex.Corporation.print c
    for p <- players(), do: Acquirex.Player.print p
  end

  def print_current_order do
    co = current_order
    co_str = co |> Enum.map(&Atom.to_string/1) |> Enum.join ", "
    IO.puts "#{co_str}"
  end

  def ongoing(:current_order, _from, s) do
    {:reply, s.players, :ongoing, s}
  end

  def ongoing(:next, %{players: [h|t]}=s) do
    {:next_state, :ongoing, %{s| players: t ++ [h]}}
  end

  def ongoing(:finish, s) do
    {:next_state, :completed, s}
  end
 
  defp sort_initial(xs) do
    Enum.sort(xs, fn ({_,t1},{_,t2}) -> Acquirex.Tiles.greater_than(t1, t2) end)
  end

  defp rotate_until(first, [first|_]=players), do: players
  defp rotate_until(first, [h|t]), do: [rotate_until(first, t)] ++ [h]

  ## callbacks

  def handle_info(_, _state_name, s) do
    {:stop, :unexpected_message, s}
  end

  def handle_sync_event(:status, _from, state_name, s) do
    reply = state_name
    {:reply, reply, state_name, s}
  end

  def handle_sync_event(:players, _from, state_name, s) do
    {:reply, s.players, state_name, s}
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

  defp print_column_header() do
    IO.puts(" 123456789012")
  end

  defp print_rows() do
    res = ""
    for row <- ?a..?i do
      IO.write(String.Chars.to_string([row]))
      for column <- 1..12 do
        IO.write(Acquirex.Space.status({column, [row]}) |> content_to_string)
      end
      IO.write(String.Chars.to_string([row]))
      IO.puts ""
    end
  end

  def content_to_string(Empty), do: "."
  def content_to_string(Full),  do: "*" 
  def content_to_string({Incorporated, c}) do
    corp_to_letter(c)
  end

  defp corp_to_letter(c) do
    Atom.to_string(c) |> String.at(7)
  end
  
end
