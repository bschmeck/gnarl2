defmodule Gnarl.Updater do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    Process.send_after(self(), :scores, :timer.minutes(1))
    Process.send_after(self(), :probabilities, :timer.minutes(1))
    {:ok, state}
  end

  def handle_info(:scores, state) do
    Fetcher.scores |> GameServer.update_scores
    Process.send_after(self(), :scores, :timer.minutes(1))
    {:noreply, state}
  end

  def handle_info(:probabilities, state) do
    Fetcher.probabilities |> GameServer.update_probabilities
    Process.send_after(self(), :probabilities, :timer.minutes(1))
    {:noreply, state}
  end
end
