defmodule Acquirex.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def init(:no_args) do
    children = [supervisor(Acquirex.Corporation.Supervisor, []),
                supervisor(Acquirex.Space.Supervisor, [])]
    supervise(children, strategy: :one_for_one)
  end

end
