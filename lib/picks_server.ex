defmodule PicksServer do
  use GenServer

  # Client

  def start_link do
    default_week = {2017, 1}
    state = %{current_week: default_week, picks: %{} }
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
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
    picks = picks |> Enum.map(fn(p) -> Canonicalize.team_abbr(p) end)

    week = {season, week}
    all_picks = Map.put(all_picks, week, picks)
    current_week = if week > current_week, do: week, else: current_week

    state = state
    |> Map.put(:picks, all_picks)
    |> Map.put(:current_week, current_week)

    {:noreply, state}
  end

  def handle_call({:current_week}, _from, state = %{current_week: week}) do
    {:reply, {:ok, week}, state}
  end

  def handle_call({:get_picks, season, week}, _from, state = %{picks: picks}) do
    week = {season, week}
    week_picks = Map.get(picks, week, [])

    {:reply, {:ok, week_picks}, state}
  end
end
