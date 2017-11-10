defmodule GnarlWeb.ApiController do
  use GnarlWeb, :controller

  def ev(conn, _params) do
    with {:ok, ev} <- PicksServer.ev_of(2017, 10) do
      json conn, ev |> Map.from_struct
    end
  end

  def scores(conn, _params) do
    with {:ok, games} <- GameServer.games({2017, 10}) do
      scores = games |> Enum.map(fn {key, game} -> %{fields: game |> Map.from_struct} end)
      json conn, scores
    end
  end
end
