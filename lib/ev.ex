defmodule EV do
  defstruct distribution: %{}, ev: 0

  def of(picks, outcomes) do
    dist = distribution_of(picks, outcomes)
    ev = ev_of(dist)

    %EV{distribution: dist, ev: ev}
  end

  defp distribution_of(_picks, []), do: %{}
  defp distribution_of(picks, [outcome | rest]) do
    # for all outcome in outcomes
    #  score = number of correct picks
    #  distribution[score] += 1
    score = score_of(picks, outcome)
    dist = distribution_of(picks, rest)
    prev = Map.get(dist, score) || 1
    Map.put(dist, score, prev * outcome.probability)
  end

  defp score_of(games, %Outcome{winners: winners}) do
    # Number of correct picks (R) is the intersection of picks with winners
    # Number of incorrect picks (I) is the size of games (S) minus the number of correct picks
    # Net score is the number correct minus the number incorrect
    # R - I = R - (S - R) = 2R - S
    correct = MapSet.intersection(MapSet.new(games), MapSet.new(winners)) |> Enum.count
    2 * correct - Enum.count(games)
  end

  defp ev_of(distribution) do
    distribution |>
      Enum.reduce(0, fn({wins, prob}, acc) -> acc + wins * prob end)
  end
end
