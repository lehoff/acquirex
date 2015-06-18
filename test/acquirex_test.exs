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
    Turn.move :bob, {2, 'g'}
    Turn.move :amy, {2, 'g'}
    Turn.move :amy, {1, 'g'}
    Game.print
    Turn.move :bob, {2, 'g'}
    Turn.inc_choice :bob, Sackson
    Game.print
    Turn.buy_choice :bob, [Sackson, Sackson, Sackson]
    Game.print
    assert 1 == 1
  end
end
