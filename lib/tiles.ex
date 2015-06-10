defmodule Acquirex.Tiles do

  @type row :: 1..12
  @type column :: ?a..?i
  @type t :: {row, column}

  def start_link() do
    Agent.start_link(fn -> all |> Enum.shuffle end, name: __MODULE__)
  end

  def draw do
    Agent.get_and_update(__MODULE__, fn([tile|tiles]) -> {tile, tiles} end)
  end

  def all do
    for row <- 1..12, column <- ?a..?i, do: {row, [column]}
  end
end
