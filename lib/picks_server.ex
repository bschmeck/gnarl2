defmodule PicksServer do
  use GenServer

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def set_picks(picks) do
    GenServer.cast(__MODULE__, {:set_picks, picks})
  end

  def ev_of(season, week) do
    GenServer.call(__MODULE__, {:ev, season, week})
  end

  # Server

  def handle_cast({:set_picks, picks}, _old_picks) do
    {:noreply, picks}
  end

  def handle_call({:ev, season, week}, _from, picks) do
    outcomes = with {:ok, games} <- GameServer.games({season, week}),
      do: games |> Map.values |> Probability.outcomes
    ev = EV.of picks, outcomes

    {:reply, {:ok, ev}, picks}
  end
end
