defmodule EVTest do
  use ExUnit.Case, async: true

  test "it computes EV when not all games are picked" do
    outcomes = [%Outcome{winners: ["A0", "A1", "A2"], probability: 0.125}, # score 0
                %Outcome{winners: ["A0", "A1", "B2"], probability: 0.125}, # score 0
                %Outcome{winners: ["A0", "B1", "A2"], probability: 0.125}, # score 1
                %Outcome{winners: ["A0", "B1", "B2"], probability: 0.125}, # score 1
                %Outcome{winners: ["B0", "A1", "A2"], probability: 0.125}, # score -1
                %Outcome{winners: ["B0", "A1", "B2"], probability: 0.125}, # score -1
                %Outcome{winners: ["B0", "B1", "A2"], probability: 0.125}, # score 0
                %Outcome{winners: ["B0", "B1", "B2"], probability: 0.125}] # score 0
    ev = EV.of(["A0", "B1"], outcomes)

    assert ev.distribution == %{1 => 0.25, -1 => 0.25, 0 => 0.5}
    assert ev.ev == 0
  end

  test "it computes EV of multiple games" do
    outcomes = [%Outcome{winners: ["A0", "A1"], probability: 0.1}, # score 0
                %Outcome{winners: ["A0", "B1"], probability: 0.4}, # score 1
                %Outcome{winners: ["B0", "A1"], probability: 0.2}, # score -1
                %Outcome{winners: ["B0", "B1"], probability: 0.3}] # score 0
    ev = EV.of(["A0", "B1"], outcomes)

    assert ev.distribution == %{1 => 0.4, -1 => 0.2, 0 => 0.4}
    assert ev.ev == 0.2
  end

  test "distribution values sum to 1" do
    outcomes = [
      %Game{home_team: "A0", home_prob: 0.75, away_team: "B0", away_prob: 0.25},
      %Game{home_team: "A1", home_prob: 0.75, away_team: "B1", away_prob: 0.25},
      %Game{home_team: "A2", home_prob: 0.75, away_team: "B2", away_prob: 0.25},
      %Game{home_team: "A3", home_prob: 0.75, away_team: "B3", away_prob: 0.25},
      %Game{home_team: "A4", home_prob: 0.75, away_team: "B4", away_prob: 0.25},
      %Game{home_team: "A5", home_prob: 0.75, away_team: "B5", away_prob: 0.25},
      %Game{home_team: "A6", home_prob: 0.75, away_team: "B6", away_prob: 0.25},
      %Game{home_team: "A7", home_prob: 0.75, away_team: "B7", away_prob: 0.25},
      %Game{home_team: "A8", home_prob: 0.75, away_team: "B8", away_prob: 0.25},
      %Game{home_team: "A9", home_prob: 0.75, away_team: "B9", away_prob: 0.25},
      %Game{home_team: "AA", home_prob: 0.75, away_team: "BA", away_prob: 0.25},
      %Game{home_team: "AB", home_prob: 0.75, away_team: "BB", away_prob: 0.25},
      %Game{home_team: "AC", home_prob: 0.75, away_team: "BC", away_prob: 0.25},
      %Game{home_team: "AD", home_prob: 0.75, away_team: "BD", away_prob: 0.25},
      %Game{home_team: "AE", home_prob: 0.75, away_team: "BE", away_prob: 0.25},
      %Game{home_team: "AF", home_prob: 0.75, away_team: "BF", away_prob: 0.25},
    ] |> Probability.outcomes

    %EV{distribution: dist} = EV.of(~w(A0 B1 A2 A3 B4 B5 B5 A6 B7 A8 A9 AA BB BC BD BE AF), outcomes)

    assert dist |> Map.values |> Enum.reduce(fn(a, b) -> a + b end) == 1
  end

  test "when a loss is not possible" do
    outcomes = [%Outcome{winners: ["A0", "A1"], probability: 0.1},
                %Outcome{winners: ["A0", "B1"], probability: 0.9}]
    ev = EV.of(["A0", "B1"], outcomes)

    assert ev.distribution == %{1 => 0.9, 0 => 0.1}
  end


  test "when a win is not possible" do
    outcomes = [%Outcome{winners: ["A0", "A1"], probability: 0.1},
                %Outcome{winners: ["A0", "B1"], probability: 0.9}]
    ev = EV.of(["B0", "B1"], outcomes)

    assert ev.distribution == %{-1 => 0.1, 0 => 0.9}
  end

  test "when only a win is possible" do
    outcomes = [%Outcome{winners: ["A0", "A1"], probability: 1.0}]
    ev = EV.of(["A0", "A1"], outcomes)

    assert ev.distribution == %{1 => 1.0}
  end

  test "when only a loss is possible" do
    outcomes = [%Outcome{winners: ["A0", "A1"], probability: 1.0}]
    ev = EV.of(["B0", "B1"], outcomes)

    assert ev.distribution == %{-1 => 1.0}
  end
end
