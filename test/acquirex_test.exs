defmodule AcquirexTest do
  use ExUnit.Case

  alias Acquirex.Turn
  alias Acquirex.Game
  alias Acquirex.Space
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
    Turn.move :chad, {4, 'f'}
    Turn.buy_choice :chad, [Sackson, Sackson, Sackson]
    Game.print
    Turn.move :dan, {3, 'e'}
    Turn.buy_choice :dan, []
    Game.print
    Turn.move :amy, {3, 'f'}
    Turn.inc_choice :amy, Fusion
    Turn.buy_choice :amy, [Fusion, Fusion, Fusion]
    Game.print
    Turn.move :bob, {1, 'b'}
    Turn.buy_choice :bob, [Sackson, Fusion, Fusion]
    Game.print
    Turn.move :chad, {9, 'c'}
    Turn.buy_choice :chad, [Sackson, Sackson, Sackson]
    Game.print
    Turn.move :dan, {2, 'a'}
    Turn.buy_choice :dan, [Sackson, Sackson, Sackson]
    Game.print
    IO.puts "#{Space.status {2,'a'}}"
    IO.puts "#{Space.move_outcome {3, 'a'}}"
    Turn.move :amy, {3, 'a'}
    Turn.inc_choice :amy, Quantum
    Turn.buy_choice :amy, [Sackson, Sackson, Quantum]
    Game.print
    IO.puts "#{inspect(Space.status {2,'a'})}"
    Game.print
    Turn.move :bob, {7, 'c'}
    Turn.buy_choice :bob, [Fusion, Fusion, Fusion]
    Game.print
    Turn.move :chad, {10, 'e'}
    Turn.buy_choice :chad, [Quantum, Quantum, Quantum]
    Game.print
    Turn.move :dan, {5,'f'}
    Turn.buy_choice :dan, [Quantum, Quantum, Quantum]
    Game.print
    Turn.move :amy, {9, 'd'}
    Turn.inc_choice :amy, Phoenix
    Turn.buy_choice :amy, [Phoenix, Phoenix, Phoenix]
    Game.print
    Turn.move :bob, {11, 'd'}
    Turn.buy_choice :bob, [Phoenix, Phoenix, Phoenix]
    Game.print
    Turn.move :chad, {7, 'd'}
    Turn.inc_choice :chad, Hydra
    Turn.buy_choice :chad, [Hydra, Hydra, Hydra]
    Game.print
    Turn.move :dan, {12, 'd'}
    Turn.inc_choice :dan, America
    Turn.buy_choice :dan, [America, America, America]
    Game.print
    Turn.move :amy, {10, 'i'}
    Turn.inc_choice :amy, Zeta
    Turn.buy_choice :amy, [Zeta, Zeta, Zeta]
    Game.print
    Turn.move :bob, {12, 'g'} # this should be illegal!!
    Turn.buy_choice :bob, [America, America, America]
    IO.puts "#{inspect(Space.move_outcome {9, 'e'})}"
    IO.puts "#{inspect(Space.neighbour_status {9, 'e'})}"
    Game.print
    Turn.move :chad, {9, 'e'}
    Turn.buy_choice :chad, [America, America, America]
    Game.print
    Turn.move :dan, {5, 'g'}
    Turn.buy_choice :dan, [Sackson, Sackson, Sackson]
    Game.print
    Turn.move :amy, {10, 'f'}
    Turn.buy_choice :amy, [Hydra, Hydra, Hydra]
    Game.print
    Turn.move :bob, {10, 'd'}
    Game.print
    Game.print
    assert 1 == 1
  end
end
