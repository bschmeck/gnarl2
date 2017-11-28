defmodule GnarlWeb.PageController do
  use GnarlWeb, :controller

  def index(conn, _params) do
    {:ok, {season, week}} = PicksServer.current_week

    conn
    |> assign(:season, season)
    |> assign(:week, week)
    |> render("index.html")
  end
end
