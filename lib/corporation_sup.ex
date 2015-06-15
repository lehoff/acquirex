defmodule Acquirex.Corporation.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def init(:no_args) do
    children = for c <- Acquirex.Corporation.all do
      worker(Acquirex.Corporation, [c], id: c)
    end
    supervise(children, strategy: :one_for_one)
  end
end
