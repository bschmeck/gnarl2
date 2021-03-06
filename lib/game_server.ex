defmodule GameServer do
  use GenServer

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def update_scores({season, week, scores}) do
    GenServer.cast(__MODULE__, {:update_scores, season, week, scores})
  end

  def update_probabilities({season, week, probabilities}) do
    GenServer.cast(__MODULE__, {:update_probabilities, season, week, probabilities})
  end

  def games({season, week}) do
    GenServer.call(__MODULE__, {:games, season, week})
  end

  # Server

  def handle_call({:games, season, week}, _from, games) do
    key = week_key_for(season, week)
    ret = Map.get(games, key)
    {:reply, {:ok, ret}, games}
  end

  def handle_cast({:update_scores, season, week, scores}, games) do
    key = week_key_for(season, week)
    games_for_week = Map.get(games, key, %{})
    games_for_week = update_games_by_scores(games_for_week, scores)
    games = Map.put(games, key, games_for_week)

    {:noreply, games}
  end

  def handle_cast({:update_probabilities, season, week, probabilities}, games) do
    key = week_key_for(season, week)
    games_for_week = Map.get(games, key, %{})
    games_for_week = update_games_by_probabilities(games_for_week, probabilities)
    games = Map.put(games, key, games_for_week)

    {:noreply, games}
  end

  defp update_games_by_scores(games, [score | rest]) do
    updated = update_games_by_scores(games, rest)
    update_game_by_score(updated, score)
  end
  defp update_games_by_scores(games, []), do: games

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

  defp week_key_for(season, week), do: "#{season}-#{week}"

  defp game_key_for(%Game{away_team: away, home_team: home}), do: "#{away}@#{home}"

  defp update_games_by_probabilities(games, [{team, prob} | rest]) do
    updated = update_games_by_probabilities(games, rest)
    update_game_by_probability(updated, team, prob)
  end
  defp update_games_by_probabilities(games, []), do: games

  defp update_game_by_probability(games, team, probability) do
    game = games |> game_with_team(team)

    if game == nil do
      games
    else
      updated = game |> update_probabilities({team, probability})
      key = game_key_for(updated)
      Map.put(games, key, updated)
    end
  end

  defp game_with_team(games, team) do
    games
    |> Map.values
    |> Enum.find(fn
      (%Game{home_team: ^team}) -> true
      (%Game{away_team: ^team}) -> true
      (_) -> false
    end)
  end

  defp update_probabilities(%Game{away_team: team} = game, {team, probability}) do
    home_prob = 1 - probability |> Float.round(3)
    %Game{game | away_prob: probability, home_prob: home_prob}
  end

  defp update_probabilities(%Game{home_team: team} = game, {team, probability}) do
    away_prob = 1 - probability |> Float.round(3)
    %Game{game | home_prob: probability, away_prob: away_prob}
  end
end
