defmodule GameServerTest do
  use ExUnit.Case

  test "it adds new games" do
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, games} = GameServer.handle_cast({:update_scores, [score]}, %{})
    assert games |> Map.values |> Enum.count == 1
  end

  test "it updates existing games" do
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, games} = GameServer.handle_cast({:update_scores, [score]}, %{})
    score = %Game{away_team: "A0", away_score: 10, home_team: "B0", home_score: 21, time_left: "HALFTIME"}
    {:noreply, games} = GameServer.handle_cast({:update_scores, [score]}, games)

    assert games |> Map.values |> hd == score
  end

  test "it adds probabilities to existing games when given the away team's prob" do
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, games} = GameServer.handle_cast({:update_scores, [score]}, %{})
    {:noreply, games} = GameServer.handle_cast({:update_probabilities, [{"A0", 0.75}]}, games)

    game = games |> Map.values |> hd
    assert game.away_prob == 0.75
    assert game.home_prob == 1 - 0.75
  end

  test "it adds probabilities to existing games when given the home team's prob" do
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, games} = GameServer.handle_cast({:update_scores, [score]}, %{})
    {:noreply, games} = GameServer.handle_cast({:update_probabilities, [{"B0", 0.82}]}, games)

    game = games |> Map.values |> hd
    assert game.away_prob == 1 - 0.82
    assert game.home_prob == 0.82
  end

  test "it ignores probabilities for non-existent games" do
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, old_games} = GameServer.handle_cast({:update_scores, [score]}, %{})
    {:noreply, new_games} = GameServer.handle_cast({:update_probabilities, [{"B1", 0.82}]}, old_games)

    assert old_games == new_games
  end
end
