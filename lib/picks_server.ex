defmodule PicksServer do
  use GenServer

  require Ecto.Query

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, state_from_db(), name: __MODULE__)
  end

  def set_picks(season, week, picks) do
    GenServer.cast(__MODULE__, {:set_picks, season, week, picks})
  end

  def picks_for(season, week) do
    GenServer.call(__MODULE__, {:get_picks, season, week})
  end

  def current_week do
    GenServer.call(__MODULE__, {:current_week})
  end

  # Server

  def handle_cast({:set_picks, season, week, picks}, state = %{current_week: current_week, picks: all_picks}) do
    picks = canonicalize(picks)

    week = {season, week}
    all_picks = Map.put(all_picks, week, picks)
    current_week = if week > current_week, do: week, else: current_week

    state = state
    |> Map.put(:picks, all_picks)
    |> Map.put(:current_week, current_week)

    {:noreply, state}
  end

  def canonicalize([]), do: []
  def canonicalize([pick = %Gnarl.Pick{winner: team} | rest]) do
    [ %Gnarl.Pick{pick | winner: Canonicalize.team_abbr(team)} | canonicalize(rest) ]
  end

  def handle_call({:current_week}, _from, state = %{current_week: week}) do
    {:reply, {:ok, week}, state}
  end

  def handle_call({:get_picks, season, week}, _from, state = %{picks: picks}) do
    week = {season, week}
    week_picks = Map.get(picks, week, [])

    {:reply, {:ok, week_picks}, state}
  end

  defp state_from_db do
    picks = Gnarl.Pick
    |> Gnarl.Repo.all
    |> Enum.group_by(&({&1.season, &1.week}))

    current_season = Gnarl.Repo.one(Ecto.Query.from p in Gnarl.Pick, select: max(p.season))
    current_week = Gnarl.Repo.one(Ecto.Query.from p in Gnarl.Pick, where: p.season == ^current_season, select: max(p.week))

    %{
      current_week: {current_season, current_week},
      picks: picks
    }
  end
end
