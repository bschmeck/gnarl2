defmodule Game do
  defstruct [:away_team,
             :away_prob,
             :away_score,
             :home_team,
             :home_prob,
             :home_score,
             :start_time,
             :time_left]
end

defimpl Inspect, for: Game do
  def inspect(game, _opts) do
    "#{game.away_team} @ #{game.home_team} #{game.away_score}-#{game.home_score} #{game.time_left}"
  end
end
