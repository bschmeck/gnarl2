defmodule EVTest do
  use ExUnit.Case, async: true
  use Quixir

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
    ptest games: list(of: Pollution.VG.struct(%Game{home_team: string(min: 2, max: 3, chars: :upper),
                                                home_prob: float(min: 0.0, max: 1.0),
                                                home_score: positive_int(),
                                                away_team: string(min: 2, max: 3, chars: :upper),
                                                away_score: positive_int(),
                                                time_left: string(chars: :printable, max: 5)
                                               }), min: 1, max: 16) do
      outcomes = games
      |> Enum.map(fn(game) -> %Game{game | away_prob: 1 - game.home_prob} end)
      |> Probability.outcomes

      %EV{distribution: dist} = outcomes |> Enum.take_random(1) |> EV.of(outcomes)

      assert_in_delta dist |> Map.values |> Enum.reduce(fn(a, b) -> a + b end), 1.0, 0.0000001
    end
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
