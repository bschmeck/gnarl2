defmodule GnarlWeb.Admin.PicksController do
  use GnarlWeb, :controller

  require Ecto.Query

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
    {:ok, picks} = PicksServer.picks_for(season, week)

    conn
    |> assign(:season, season)
    |> assign(:week, week)
    |> assign(:picks, list_picks(picks))
    |> assign(:ben_lock, find_lock(picks, "BEN"))
    |> assign(:brian_lock, find_lock(picks, "BRIAN"))
    |> assign(:ben_antilock, find_antilock(picks, "BEN"))
    |> assign(:brian_antilock, find_antilock(picks, "BRIAN"))
    |> render("show.html")
  end

  def create(conn, params = %{"season" => season, "week" => week}) when is_binary(season) and is_binary(week) do
    {season, ""} = Integer.parse(season)
    {week, ""} = Integer.parse(week)

    params = params |> Map.put("season", season) |> Map.put("week", week)
    create(conn, params)
  end

  def create(conn, %{"season" => season, "week" => week, "ben_picks" => ben_picks, "brian_picks" => brian_picks, "ben_lock" => ben_lock, "brian_lock" => brian_lock, "ben_antilock" => ben_antilock, "brian_antilock" => brian_antilock}) do
    q = Ecto.Query.from p in "picks", where: p.season == ^season, where: p.week == ^week
    Gnarl.Repo.delete_all(q)

    ben_picks = ben_picks |> Enum.reject(&(&1 == ""))
    brian_picks = brian_picks |> Enum.reject(&(&1 == ""))
    picks = Gnarl.Pick.build("BEN", ben_picks, ben_lock, brian_antilock) ++ Gnarl.Pick.build("BRIAN", brian_picks, brian_lock, ben_antilock)
    Enum.each(picks, &(Gnarl.Repo.insert(%Gnarl.Pick{&1 | season: season, week: week})))

    PicksServer.set_picks(season, week, picks)
    redirect conn, to: page_path(conn, :index)
  end

  defp list_picks([]) do
    [{1, "", ""}, {2, "", ""}, {3, "", ""}, {4, "", ""}, {5, "", ""}, {6, "", ""}, {7, "", ""}, {8, "", ""}]
  end

  defp list_picks(picks) do
    grouped = Enum.group_by(picks, &(&1.slot))
    grouped
    |> Map.keys
    |> Enum.sort
    |> Enum.map(fn(slot) -> grouped |> Map.get(slot) |> winners(slot) end)
  end

  defp winners(slotted, slot) do
    {
      slot,
      Enum.find(slotted, &(&1.picker == "BEN")).winner,
      Enum.find(slotted, &(&1.picker == "BRIAN")).winner
    }
  end

  defp find_lock([], _picker), do: ""
  defp find_lock([%Gnarl.Pick{picker: picker, lock: true, winner: winner} | _rest], picker), do: winner
  defp find_lock([_pick | rest], picker), do: find_lock(rest, picker)
  defp find_antilock([], _picker), do: ""
  defp find_antilock([%Gnarl.Pick{picker: picker, antilock: true, winner: winner} | _rest], picker), do: winner
  defp find_antilock([_pick | rest], picker), do: find_antilock(rest, picker)
end
