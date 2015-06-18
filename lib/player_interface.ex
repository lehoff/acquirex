defmodule Acquirex.Player.Interface do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: {:via, :gproc, player_name(name)})
  end

  def info(name, msg) do
    GenServer.cast({:via, :gproc, player_name(name)}, {:info, msg})
  end

  ## callbacks
  def init(name) do
    {:ok, %{name: name, games: []}}
  end

  def handle_cast({:info, msg}, s) do
#    IO.puts "#{s.name} received info: #{IO.inspect(msg)}"
    :io.format("~p received info: ~p~n", [s.name, msg])
    {:noreply, s}
  end

  def handle_info(msg, s) do
    IO.puts "#{s.name} got: #{IO.inspect(msg)}"
    {:noreply, s}
  end

  defp player_name(name) do
    {:n, :l, {__MODULE__, name}}
  end
end
