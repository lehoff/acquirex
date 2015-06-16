defmodule Acquirex.Tiles do

  @type column :: 1..12
  @type row :: ?a..?i
  @type t :: {column, row}  # Acquire has a weird coordinate system :-(

  def start_link() do
    Agent.start_link(fn -> all |> Enum.shuffle end, name: __MODULE__)
  end

  def draw do
    Agent.get_and_update(__MODULE__, fn([tile|tiles]) -> {tile, tiles} end)
  end

  def all do
    for row <- ?a..?i, column <- 1..12,  do: {column, [row]}
  end

  def greater_than({c1, r1}, {c2,r2}) do
    r2 > r1 or c2 > c1
  end
end
