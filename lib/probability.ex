defmodule Probability do
  def outcomes(games), do: do_outcomes(games, [%Outcome{}])

  defp do_outcomes([], results), do: results
  defp do_outcomes([game = %Game{away_prob: 0} | rest], results) do
    do_outcomes(rest, results)
    |> Enum.map(fn(o) -> add_winner(o, game.home_team, game.home_prob) end)
  end
  defp do_outcomes([game = %Game{home_prob: 0} | rest], results) do
    do_outcomes(rest, results)
    |> Enum.map(fn(o) -> add_winner(o, game.away_team, game.away_prob) end)
  end
  defp do_outcomes([game | rest], results) do
    do_outcomes(rest, results)
    |> Enum.flat_map(fn(o) ->
      [
        add_winner(o, game.away_team, game.away_prob),
        add_winner(o, game.home_team, game.home_prob)
      ]
    end)
  end

  defp add_winner(%Outcome{winners: winners, probability: probability}, winner, winner_probability) do
    %Outcome{ winners: [winner | winners], probability: probability * winner_probability }
  end
end
