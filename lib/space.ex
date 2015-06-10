defmodule Acquirex.Space do

  alias Acquirex.Corporation, as: Corp
  @type status :: Empty | Full | {Incorporated, Corp.t}

  def start_link(coord) do
    Agent.start_link(fn -> Empty end, name: {:via, :gproc, space_name(coord)})
  end

  def status(coord) do
    Agent.get({:via, :gproc, space_name(coord)}, fn s -> s end)
  end

  def fill_consequence(coord) do
    :ok
  end

  defp space_name(coord) do
    {:n, :l, {__MODULE__, coord}}
  end
end
