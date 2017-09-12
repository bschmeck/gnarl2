defmodule GameServerTest do
  use ExUnit.Case

  test "it adds new games" do
    state = %{}
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, state} = GameServer.handle_cast({:update_scores, 2017, 1, [score]}, state)

    {:reply, {:ok, games}, _state} = GameServer.handle_call({:games, 2017, 1}, nil, state)

    assert games |> Map.values |> Enum.count == 1
  end

  test "it updates existing games" do
    state = %{}
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, state} = GameServer.handle_cast({:update_scores, 2017, 1, [score]}, state)
    score = %Game{away_team: "A0", away_score: 10, home_team: "B0", home_score: 21, time_left: "HALFTIME"}
    {:noreply, state} = GameServer.handle_cast({:update_scores, 2017, 1, [score]}, state)

    {:reply, {:ok, games}, _state} = GameServer.handle_call({:games, 2017, 1}, nil, state)

    assert games |> Map.values |> hd == score
  end

  test "it adds probabilities to existing games when given the away team's prob" do
    state = %{}
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, state} = GameServer.handle_cast({:update_scores, 2017, 1, [score]}, state)
    {:noreply, state} = GameServer.handle_cast({:update_probabilities, 2017, 1, [{"A0", 0.75}]}, state)

    {:reply, {:ok, games}, _state} = GameServer.handle_call({:games, 2017, 1}, nil, state)

    game = games |> Map.values |> hd
    assert game.away_prob == 0.75
    assert game.home_prob == 0.25
  end

  test "it adds probabilities to existing games when given the home team's prob" do
    state = %{}
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, state} = GameServer.handle_cast({:update_scores, 2017, 1, [score]}, state)
    {:noreply, state} = GameServer.handle_cast({:update_probabilities, 2017, 1, [{"B0", 0.82}]}, state)

    {:reply, {:ok, games}, _state} = GameServer.handle_call({:games, 2017, 1}, nil, state)

    game = games |> Map.values |> hd
    assert game.away_prob == 0.18
    assert game.home_prob == 0.82
  end

  test "it ignores probabilities for non-existent games" do
    state = %{}
    score = %Game{away_team: "A0", away_score: 0, home_team: "B0", home_score: 0, time_left: "PREGAME"}
    {:noreply, old_state} = GameServer.handle_cast({:update_scores, 2017, 1, [score]}, state)
    {:noreply, new_state} = GameServer.handle_cast({:update_probabilities, 2017, 1, [{"B1", 0.82}]}, old_state)

    assert old_state == new_state
  end
end
