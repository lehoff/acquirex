defmodule Acquirex.Player.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def new_player(name) do
    Supervisor.start_child(__MODULE__, [name])
  end

  def init(:no_args) do
    child = [supervisor(Acquirex.Player, [])]
    supervise(child, strategy: :simple_one_for_one)
  end
end
