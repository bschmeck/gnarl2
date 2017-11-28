defmodule PicksServer do
  use GenServer

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def set_picks(picks) do
    GenServer.cast(__MODULE__, {:set_picks, picks})
  end

  def get_picks do
    GenServer.call(__MODULE__, {:get_picks})
  end

  def ev_of(season, week) do
    GenServer.call(__MODULE__, {:ev, season, week})
  end

  def current_week do
    {:ok, {2017, 12}}
  end
  # Server

  def handle_cast({:set_picks, picks}, _old_picks) do
    picks = picks |> Enum.map(fn(p) -> Canonicalize.team_abbr(p) end)

    {:noreply, picks}
  end

  def handle_call({:get_picks}, _from, picks) do
    {:reply, {:ok, picks}, picks}
  end

  def handle_call({:ev, season, week}, _from, picks) do
    outcomes = with {:ok, games} <- GameServer.games({season, week}),
      do: games |> Map.values |> Probability.outcomes
    ev = EV.of picks, outcomes

    {:reply, {:ok, ev}, picks}
  end
end
