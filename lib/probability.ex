defmodule Probability do
  def outcomes(games), do: do_outcomes(games, [%Outcome{}])

  defp do_outcomes([], results), do: results
  defp do_outcomes([game | rest], results) do
    rest
    |> do_outcomes(results)
    |> Enum.flat_map(possible_winners_fn(game))
  end

  defp possible_winners_fn(%Game{away_prob: 0, home_team: team, home_prob: prob}) do
    &([add_winner(&1, team, prob)])
  end
  defp possible_winners_fn(%Game{home_prob: 0, away_team: team, away_prob: prob}) do
    &([add_winner(&1, team, prob)])
  end
  defp possible_winners_fn(game) do
    fn(o) ->
      [
        add_winner(o, game.away_team, game.away_prob),
        add_winner(o, game.home_team, game.home_prob)
      ]
    end
  end

  defp add_winner(%Outcome{winners: winners, probability: probability}, winner, winner_probability) do
    %Outcome{winners: [winner | winners], probability: probability * winner_probability}
  end
end
