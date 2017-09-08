defmodule Canonicalize do
  def team_abbr("WSH"), do: "WAS"
  def team_abbr("JAC"), do: "JAX"
  def team_abbr("STL"), do: "LAR"
  def team_abbr(abbr), do: abbr
end
