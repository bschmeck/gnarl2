defmodule Probability do
  def outcomes(games), do: do_outcomes(games, [%Outcome{}])

  defp do_outcomes([], results), do: results
  defp do_outcomes([game | rest], results) do
    other_outcomes = do_outcomes(rest, results)

    away_outcomes = other_outcomes |> Enum.map(fn(o) -> add_winner(o, game.away_team, game.away_prob) end)
    home_outcomes = other_outcomes |> Enum.map(fn(o) -> add_winner(o, game.home_team, game.home_prob) end)

    away_outcomes ++ home_outcomes
  end

  defp add_winner(%Outcome{winners: winners, probability: probability}, winner, winner_probability) do
    %Outcome{ winners: [winner | winners], probability: probability * winner_probability }
  end
end
