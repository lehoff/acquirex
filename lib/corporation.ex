defmodule Acquirex.Corporation do

  @type t :: Sackson | Zeta | Hydra | Fusion | America | Phoenix | Quantum

  @base_tier %{Sackson: 0, Zeta: 0,
               Hydra: 1, Fusion: 1, America: 1,
               Phoenix: 2, Quantum: 2}

  @spec tier(t, non_neg_integer) :: 1..11
  def tier(c, count) do
    @base_tier[c] + raw_tier(count)
  end

  @spec tier_bonus(1..11) :: {non_neg_integer, non_neg_integer}
  def tier_bonus(tier) do
    majority = (tier + 1)*1_000
    {majority, div(majority, 2)}
  end

  defp raw_tier(count) when count <=  6, do: count-1
  defp raw_tier(count) when count <= 10, do: 5
  defp raw_tier(count) when count <= 20, do: 6
  defp raw_tier(count) when count <= 30, do: 7
  defp raw_tier(count) when count <= 40, do: 8
  defp raw_tier(count) when count >= 41, do: 9

end
