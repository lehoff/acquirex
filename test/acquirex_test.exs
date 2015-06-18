defmodule AcquirexTest do
  use ExUnit.Case

  alias Acquirex.Turn
  alias Acquirex.Game
  alias Acquirex.Player.Supervisor, as: PlayerSup

  test "sample 4 player game" do
    players = [:amy, :bob, :chad, :dan]
    for p <- players, do: PlayerSup.new_player p
    Game.begin
    Game.print
    Turn.move :amy, {1, }
    assert 1 == 1
  end
end
