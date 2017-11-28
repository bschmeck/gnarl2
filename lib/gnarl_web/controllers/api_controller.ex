defmodule GnarlWeb.ApiController do
  use GnarlWeb, :controller

  def ev(conn, _params) do
    with {:ok, ev} <- PicksServer.ev_of(2017, 12) do
      json conn, ev |> Map.from_struct
    end
  end

  def scores(conn, %{"season" => season, "week" => week}) when is_binary(season) and is_binary(week) do
    {season, ""} = Integer.parse(season)
    {week, ""} = Integer.parse(week)

    scores(conn, %{"season" => season, "week" => week})
  end

  def scores(conn, %{"season" => season, "week" => week}) when season >= 2017 and week in (1..17) do
    with {:ok, games} <- GameServer.games({season, week}),
         {:ok, picks} <- PicksServer.get_picks do
      count = Enum.count(picks)
      {mine, his} = Enum.split(picks, div(count, 2))
      my_scores = mine |> Enum.map(fn pick ->
        %{fields: games
        |> game_for(pick)
        |> Map.from_struct
        |> Map.put("picked_team", pick)
        |> Map.put("picker", "BEN")}
      end)

      his_scores = his |> Enum.map(fn pick ->
        game = games |> game_for(pick)
        picked_team = other_team(pick, game)
        %{fields: game
        |> Map.from_struct
        |> Map.put("picked_team", picked_team)
        |> Map.put("picker", "BRIAN")}
      end)

      json conn, my_scores ++ his_scores
    end
  end

  defp game_for(games, team) do
    games |> Enum.find(fn
      {_key, %Game{home_team: ^team}} -> true
      {_key, %Game{away_team: ^team}} -> true
      {_key, _game} -> false
    end) |> elem(1)
  end

  defp other_team(team, %Game{home_team: team, away_team: other}), do: other
  defp other_team(team, %Game{away_team: team, home_team: other}), do: other
end
