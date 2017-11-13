defmodule GnarlWeb.ApiController do
  use GnarlWeb, :controller

  def ev(conn, _params) do
    with {:ok, ev} <- PicksServer.ev_of(2017, 10) do
      json conn, ev |> Map.from_struct
    end
  end

  def scores(conn, _params) do
    with {:ok, games} <- GameServer.games({2017, 10}),
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
        %{fields: games
        |> game_for(pick)
        |> Map.from_struct
        |> Map.put("picked_team", pick)
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
end
