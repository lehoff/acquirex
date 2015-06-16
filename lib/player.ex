defmodule Acquirex.Player do
  use Supervisor

  def start_link(name) do
    {:ok, _} = res = Supervisor.start_link(__MODULE__, name, name: {:via, :gproc, player_name(name)})
    Acquirex.Game.join name
    res
  end

  def info(name, msg) do
    Acquirex.Player.Interface.info(name, msg)
  end

  def print(name) do
    cash = Acquirex.Player.Account.balance name
    portfolio = Acquirex.Player.Portfolio.to_string name
    tiles = Acquirex.Player.Tiles.tiles name
    tiles_str = Enum.map(tiles, &Acquirex.Tiles.to_string/1) |> Enum.join ", "
    IO.puts "#{name} -- #{cash} -- #{portfolio}\n    #{tiles_str}"
  end

  ## callbacks
  def init(name) do
    children = [worker(Acquirex.Player.Interface, [name]),
                worker(Acquirex.Player.Account, [name]),
                worker(Acquirex.Player.Portfolio, [name]),
                worker(Acquirex.Player.Tiles, [name])]
    supervise(children, strategy: :one_for_one)
  end


  defp player_name(name) do
    {:n, :l, {__MODULE__, name}}
  end
end
