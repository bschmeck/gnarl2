defmodule GameServer do
  use GenServer

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def update_scores(scores) do
    GenServer.cast(__MODULE__, {:update_scores, scores})
  end

  def update_probabilities(probabilities) do
    GenServer.cast(__MODULE__, {:update_probabilities, probabilities})
  end

  # Server

  def handle_cast({:update_scores, scores}, _from, games) do
    Enum.each(scores, fn(score) -> games = update_game_by_score(games, score) end)
    {:noreply, games}
  end

  def handle_cast({:update_probabilities, probabilities}, _from, games) do
    Enum.each(probabilities, fn(probabilty) -> games = update_game_by_probability(games, probability) end)
    {:noreply, games}
  end

  defp update_game_by_score(games, score) do
    key = game_key_for(score)
    game = Map.get(games, key, %Game{away_team: score.away_team,
                                     home_team: score.home_team,
                                     start_time: score.start_time,
                                    })
    updated = %Game{game |
                    away_score: score.away_score,
                    home_score: score.home_score,
                    time_left: score.time_left
                   }
    Map.put(games, key, updated)
  end

  defp update_game_by_probability(games, {team, probability}) do
    updated = games
              |> game_with_team(team)
              |> update_probabilities({team, probability})
    key = game_key_for(updated)
    Map.put(games, key, updated)
  end

  defp game_key_for(%Game{away_team: away, home_team: home}), do: "#{away}@#{home}"
  defp game_with_team(games, team) do
    games
    |> Map.values
    |> Enum.detect(fn
      (%Game{home_team: ^team}) -> true
      (%Game{away_team: ^team}) -> true
      (_) -> false
    end)
  end

  defp update_probabilities(%Game{away_team: team} = game, {team, probability}) do
    %Game{game | away_prob: probability, home_prob: 1 - probability}
  end

  defp update_probabilities(%Game{home_team: team} = game, {team, probability}) do
    %Game{game | home_prob: probability, away_prob: 1 - probability}
  end
end
