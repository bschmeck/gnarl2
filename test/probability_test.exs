defmodule ProbabilityTest do
  use ExUnit.Case
  doctest Gnarl

  test "it works for a single game" do
    games = [%Game{home_team: "A0", home_prob: 0.5, away_team: "B0", away_prob: 0.5}]
    outcomes = Probability.outcomes(games)
    assert Enum.member?(outcomes, %Outcome{winners: ["A0"], probability: 0.5})
    assert Enum.member?(outcomes, %Outcome{winners: ["B0"], probability: 0.5})
  end

  test "it computes probabilities" do
    games = [
      %Game{home_team: "A0", home_prob: 0.75, away_team: "B0", away_prob: 0.25},
      %Game{home_team: "A1", home_prob: 0.75, away_team: "B1", away_prob: 0.25},
      %Game{home_team: "A2", home_prob: 0.75, away_team: "B2", away_prob: 0.25},
      %Game{home_team: "A3", home_prob: 0.75, away_team: "B3", away_prob: 0.25}
    ]
    outcomes = Probability.outcomes(games)
    assert Enum.member?(outcomes, %Outcome{winners: ~w(B0 B1 B2 B3), probability: :math.pow(0.25, 4)})
  end

  test "it computes all possible outcomes" do
    games = [
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
    ]

    assert Enum.count(Probability.outcomes(games)) == :math.pow(2, Enum.count(games))
  end

  test "it excludes outcomes where the away team cannot win" do
    games = [
      %Game{home_team: "A0", home_prob: 0.75, away_team: "B0", away_prob: 0.25},
      %Game{home_team: "A1", home_prob: 0.75, away_team: "B1", away_prob: 0.25},
      %Game{home_team: "A2", home_prob: 1, away_team: "B2", away_prob: 0},
      %Game{home_team: "A3", home_prob: 0.75, away_team: "B3", away_prob: 0.25}
    ]
    outcomes = Probability.outcomes(games)
    refute Enum.any?(outcomes, fn(outcome) -> outcome.probability == 0 end)
  end

  test "it excludes outcomes where the home team cannot win" do
    games = [
      %Game{home_team: "A0", home_prob: 0.75, away_team: "B0", away_prob: 0.25},
      %Game{home_team: "A1", home_prob: 0.75, away_team: "B1", away_prob: 0.25},
      %Game{home_team: "A2", home_prob: 0, away_team: "B2", away_prob: 1},
      %Game{home_team: "A3", home_prob: 0.75, away_team: "B3", away_prob: 0.25}
    ]
    outcomes = Probability.outcomes(games)
    refute Enum.any?(outcomes, fn(outcome) -> outcome.probability == 0 end)
  end
end
