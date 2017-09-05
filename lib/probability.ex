defmodule Probability do
  def fetch do
    %HTTPoison.Response{body: body} = HTTPoison.get! "https://www.numberfire.com/nfl/games"
    nodes = body |> Floki.find("div.win-probability")

    teams = nodes |> Floki.attribute("class") |> Enum.map(&team_from_classes/1)
    probabilities = nodes |> Floki.find("h4") |> Enum.map(&probability_from_h4/1)

    Enum.zip(teams, probabilities)
  end

  defp team_from_classes(classes) when is_binary(classes), do: classes |> String.split |> team_from_classes
  defp team_from_classes(["team-nfl-" <> team_abbr | _rest]), do: team_abbr
  defp team_from_classes([_head | rest]), do: team_from_classes(rest)

  defp probability_from_h4(node) do
    {prob, "%"} = node |> Floki.find("h4") |> Floki.text |> String.replace(~r/\s/, "") |> Float.parse

    prob / 100
  end

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
