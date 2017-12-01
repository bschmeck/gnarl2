defmodule PicksServer do
  use GenServer

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def set_picks(season, week, picks) do
    GenServer.cast(__MODULE__, {:set_picks, season, week, picks})
  end

  def picks_for(season, week) do
    GenServer.call(__MODULE__, {:get_picks, season, week})
  end

  def ev_of(season, week) do
    GenServer.call(__MODULE__, {:ev, season, week})
  end

  def current_week do
    GenServer.call(__MODULE__, {:current_week})
  end
  # Server

  def handle_cast({:set_picks, season, week, picks}, all_picks) do
    picks = picks |> Enum.map(fn(p) -> Canonicalize.team_abbr(p) end)
    key = key_for(season, week)
    all_picks = Map.put(all_picks, key, picks)

    {:noreply, all_picks}
  end

  def handle_call({:current_week}, _from, picks) do
    week = picks |> Map.keys |> Enum.max

    {:reply, {:ok, week}, picks}
  end

  def handle_call({:get_picks, season, week}, _from, picks) do
    key = key_for(season, week)
    week_picks = Map.get(picks, key, [])

    {:reply, {:ok, week_picks}, picks}
  end

  def handle_call({:ev, season, week}, _from, picks) do
    key = key_for(season, week)
    week_picks = Map.get(picks, key, [])
    outcomes = with {:ok, games} <- GameServer.games({season, week}),
      do: games |> Map.values |> Probability.outcomes
    ev = EV.of week_picks, outcomes

    {:reply, {:ok, ev}, picks}
  end

  def key_for(season, week), do: {season, week}
end
