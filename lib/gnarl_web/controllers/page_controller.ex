defmodule GnarlWeb.PageController do
  use GnarlWeb, :controller

  def index(conn, _params) do
    {:ok, {season, week}} = PicksServer.current_week
    {:ok, picks} = PicksServer.picks_for(season, week)
    {:ok, games} = GameServer.games({season, week})

    teams = picks |> Enum.map(fn
      (pick = %Gnarl.Pick{picker: "BEN"}) ->
        loser = game_for(games, pick.winner) |> other_team(pick.winner)
        {pick.winner, loser}
      (pick = %Gnarl.Pick{picker: "BRIAN"}) ->
        loser = game_for(games, pick.winner) |> other_team(pick.winner)
        {loser, pick.winner}
    end)

    ben_teams = teams |> Enum.map(fn(tuple) -> elem(tuple, 0) end)
    brian_teams = teams |> Enum.map(fn(tuple) -> elem(tuple, 1) end)

    conn
    |> assign(:season, season)
    |> assign(:week, week)
    |> assign(:ben_teams, ben_teams)
    |> assign(:brian_teams, brian_teams)
    |> render("index.html")
  end

  defp game_for(games, team) do
    games |> Enum.find(fn
      {_key, %Game{home_team: ^team}} -> true
      {_key, %Game{away_team: ^team}} -> true
      {_key, _game} -> false
    end) |> elem(1)
  end

  defp other_team(%Game{home_team: team, away_team: other}, team), do: other
  defp other_team(%Game{away_team: team, home_team: other}, team), do: other
end
