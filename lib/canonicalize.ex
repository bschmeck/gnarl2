defmodule Canonicalize do
  def team_abbr("WSH"), do: "WAS"
  def team_abbr("JAC"), do: "JAX"
  def team_abbr("STL"), do: "LA"
  def team_abbr("LAR"), do: "LA"
  def team_abbr(abbr), do: abbr
end
