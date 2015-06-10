defmodule Acquirex.Space.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def init(:no_args) do
    children =
      for t <- Acquirex.Tiles.all do
      worker(Acquirex.Space, [t], id: t)
    end
    supervise(children, strategy: :one_for_one)
  end

end
