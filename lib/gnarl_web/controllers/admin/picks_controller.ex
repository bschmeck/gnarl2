defmodule GnarlWeb.Admin.PicksController do
  use GnarlWeb, :controller

  def index(conn, _params) do
    {:ok, {season, week}} = PicksServer.current_week

    redirect conn, to: picks_path(conn, :show, season, week)
  end

  def show(conn, %{"season" => season, "week" => week}) when is_binary(season) and is_binary(week) do
    {season, ""} = Integer.parse(season)
    {week, ""} = Integer.parse(week)

    show(conn, %{"season" => season, "week" => week})
  end


  def show(conn, %{"season" => season, "week" => week}) when season >= 2017 and week in (1..17) do
    {:ok, {season, week}} = PicksServer.current_week

    conn
    |> assign(:season, season)
    |> assign(:week, week)
    |> render("show.html")
  end
end
