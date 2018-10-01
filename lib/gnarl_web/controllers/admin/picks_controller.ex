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

  def create(conn, params = %{"season" => season, "week" => week}) when is_binary(season) and is_binary(week) do
    {season, ""} = Integer.parse(season)
    {week, ""} = Integer.parse(week)

    params = params |> Map.put("season", season) |> Map.put("week", week)
    create(conn, params)
  end

  def create(conn, %{"season" => season, "week" => week, "ben_picks" => ben_picks, "brian_picks" => brian_picks, "ben_lock" => ben_lock, "brian_lock" => brian_lock, "ben_antilock" => ben_antilock, "brian_antilock" => brian_antilock}) do
    ben_picks = ben_picks |> Enum.reject(&(&1 == ""))
    brian_picks = brian_picks |> Enum.reject(&(&1 == ""))
    picks = Gnarl.Pick.build("BEN", ben_picks, ben_lock, brian_antilock) ++ Gnarl.Pick.build("BRIAN", brian_picks, brian_lock, ben_antilock)
    PicksServer.set_picks(season, week, picks)
    redirect conn, to: page_path(conn, :index)
  end
end
