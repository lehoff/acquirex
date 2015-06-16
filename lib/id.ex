defmodule Acquirex.Id do

  def start_link do
    Agent.start_link(fn() -> 0 end, name: __MODULE__)
  end

  def new do
    Agent.get_and_update(__MODULE__, fn(c) -> {c+1, c+1} end)
  end
  
end
