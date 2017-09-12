defmodule GameServerTest do
  use ExUnit.Case

  test "it adds new games" do
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, games} = GameServer.handle_cast({:update_scores, 2017, 1, [score]}, %{})
    assert games |> Map.values |> Enum.count == 1
  end

  test "it updates existing games" do
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, games} = GameServer.handle_cast({:update_scores, 2017, 1, [score]}, %{})
    score = %Game{away_team: "A0", away_score: 10, home_team: "B0", home_score: 21, time_left: "HALFTIME"}
    {:noreply, games} = GameServer.handle_cast({:update_scores, 2017, 1, [score]}, games)

    assert games |> Map.get("2017-1") |> Map.values |> hd == score
  end

  test "it adds probabilities to existing games when given the away team's prob" do
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, games} = GameServer.handle_cast({:update_scores, 2017, 1, [score]}, %{})
    {:noreply, games} = GameServer.handle_cast({:update_probabilities, 2017, 1, [{"A0", 0.75}]}, games)

    game = games |> Map.get("2017-1") |> Map.values |> hd
    assert game.away_prob == 0.75
    assert game.home_prob == 0.25
  end

  test "it adds probabilities to existing games when given the home team's prob" do
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, games} = GameServer.handle_cast({:update_scores, 2017, 1, [score]}, %{})
    {:noreply, games} = GameServer.handle_cast({:update_probabilities, 2017, 1, [{"B0", 0.82}]}, games)

    game = games |> Map.get("2017-1") |> Map.values |> hd
    assert game.away_prob == 0.18
    assert game.home_prob == 0.82
  end

  test "it ignores probabilities for non-existent games" do
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, old_games} = GameServer.handle_cast({:update_scores, 2017, 1, [score]}, %{})
    {:noreply, new_games} = GameServer.handle_cast({:update_probabilities, 2017, 1, [{"B1", 0.82}]}, old_games)

    assert old_games == new_games
  end
end
