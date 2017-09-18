defmodule EV do
  defstruct distribution: %{}, ev: 0, win: 0, loss: 0, push: 0

  # Expect that picks is a list of all of the teams a player wants to win.  That is,
  # picks is comprised of the teams the player picked to win and the teams the player's
  # opponent picked to lose.
  def of(picks, outcomes) do
    dist = distribution_of(picks, outcomes)
    ev = ev_of(dist)
    {win, loss, push} = win_loss_push(dist)

    %EV{distribution: dist, ev: ev, win: win, loss: loss, push: push}
  end

  defp win_loss_push(distribution) do
    %{loss: loss_odds,
      win: win_odds,
      push: push_odds} = distribution
                         |> Enum.group_by(fn({n, _p}) when n < 0 -> :loss
                                            ({n, _p}) when n > 0 -> :win
                                            ({0, _p}) -> :push end,
                                         fn({_n, p}) -> p end)
                         |> ensure_keys_exist

    { win_odds |> Enum.reduce(&(&1+&2)),
      loss_odds |> Enum.reduce(&(&1+&2)),
      push_odds |> Enum.reduce(&(&1+&2)) }
  end

  defp ensure_keys_exist(%{loss: _, win: _, push: _} = results), do: results
  defp ensure_keys_exist(%{win: _, push: _} = results), do: results |> Map.put(:loss, [0])
  defp ensure_keys_exist(%{loss: _, push: _} = results), do: results |> Map.put(:win, [0])
  defp ensure_keys_exist(%{loss: _} = results), do: results |> Map.put(:win, [0]) |> Map.put(:push, [0])
  defp ensure_keys_exist(%{win: _} = results), do: results |> Map.put(:loss, [0]) |> Map.put(:push, [0])

  defp distribution_of(_picks, []), do: %{}
  defp distribution_of(picks, [outcome | rest]) do
    # for all outcome in outcomes
    #  score = number of correct picks
    #  distribution[score] += 1
    score = score_of(picks, outcome)
    dist = distribution_of(picks, rest)
    prev = Map.get(dist, score) || 0
    Map.put(dist, score, prev + outcome.probability)
  end

  # The map step winds up double counting the score, because we're counting the difference
  # in games picked correctly and games picked incorrectly, but are only concerned with the
  # difference in games picked correctly.  Since they're inverses of each other, we wind up
  # double counting and divide by 2 on the final step, instead of adding 0.5s and dealing
  # with floats.
  #
  # E.g. Player A goes 5-3 and Player B goes 4-4, the map step will give 9 +1s and 7 -1s,
  # for a total of +2, but the player only won by a single game.
  defp score_of(games, %Outcome{winners: winners}) do
    games
    |> Enum.map(fn(g) -> if Enum.member?(winners, g), do: 1, else: -1 end)
    |> Enum.reduce(fn(val, score) -> val + score end)
    |> Kernel.div(2)
  end

  defp ev_of(distribution) do
    distribution
    |> Enum.reduce(0, fn({wins, prob}, acc) -> acc + wins * prob end)
  end
end
