defmodule Acquirex.Player do
  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, name, name: {:via, :gproc, player_name(name)})
  end

  def info(name, msg) do
    Acquirex.Player.Interface.info(name, msg)
  end

  def print(name) do
    cash = Acquirex.Player.Account.balance name
    IO.puts "#{name} -- #{cash}"
  end

  ## callbacks
  def init(name) do
    children = [worker(Acquirex.Player.Interface, [name]),
                worker(Acquirex.Player.Account, [name]),
                worker(Acquirex.Player.Portfolio, [name])]
    supervise(children, strategy: :one_for_one)
  end


  defp player_name(name) do
    {:n, :l, {__MODULE__, name}}
  end
end
