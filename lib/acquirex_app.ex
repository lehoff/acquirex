defmodule Acquirex.Application do
  use Application

  def start(_type, _args) do
    Acquirex.Supervisor.start_link()
  end
end

