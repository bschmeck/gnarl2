defmodule GnarlWeb.ApiController do
  use GnarlWeb, :controller

  def ev(conn, %{"season" => season, "week" => week}) when is_binary(season) and is_binary(week) do
    {season, ""} = Integer.parse(season)
    {week, ""} = Integer.parse(week)

    ev(conn, %{"season" => season, "week" => week})
  end

  def ev(conn, %{"season" => season, "week" => week}) when season >= 2017 and week in (1..17) do
    ev = with {:ok, picks} <- PicksServer.picks_for(season, week),
              {:ok, games} <- GameServer.games({season, week})
         do
           outcomes = games |> Map.values |> Probability.outcomes
           picks = picks |> Enum.map(fn
             %Gnarl.Pick{winner: pick, picker: "BEN"} -> pick
             %Gnarl.Pick{winner: pick} -> games |> game_for(pick) |> other_team(pick)
           end)

           EV.of picks, outcomes
         end

    json conn, ev |> Map.from_struct
  end

  def scores(conn, %{"season" => season, "week" => week}) when is_binary(season) and is_binary(week) do
    {season, ""} = Integer.parse(season)
    {week, ""} = Integer.parse(week)

    scores(conn, %{"season" => season, "week" => week})
  end

  def scores(conn, %{"season" => season, "week" => week}) when season >= 2017 and week in (1..17) do
    with {:ok, games} <- GameServer.games({season, week}),
         {:ok, picks} <- PicksServer.picks_for(season, week) do

      scores = picks
      |> Enum.sort_by(fn %Gnarl.Pick{slot: slot} -> slot end)
      |> Enum.map(fn %Gnarl.Pick{winner: pick, picker: picker} ->
        %{fields: games
        |> game_for(pick)
        |> Map.from_struct
        |> Map.put("picked_team", pick)
        |> Map.put("picker", picker)}
      end)

      json conn, scores
    end
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
