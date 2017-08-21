defmodule EVTest do
  use ExUnit.Case

  test "it computes EV of a single outcome" do
    outcomes = [%Outcome{winners: ["A0"], probability: 1}]
    assert EV.of(["A0"], outcomes) == %EV{ distribution: %{ 1 => 1 }, ev: 1 }
    assert EV.of(["B0"], outcomes) == %EV{ distribution: %{ -1 => 1 }, ev: -1 }
  end

  test "it computes EV when not all games are picked" do
    outcomes = [%Outcome{winners: ["A0", "A1"], probability: 1}]
    assert EV.of(["A0"], outcomes) == %EV{ distribution: %{ 1 => 1 }, ev: 1 }
    assert EV.of(["B0"], outcomes) == %EV{ distribution: %{ -1 => 1 }, ev: -1 }
  end

  test "it computes EV when not all games are decided" do
    outcomes = [%Outcome{winners: ["A0"], probability: 0.1},
                %Outcome{winners: ["B0"], probability: 0.9}]
    assert EV.of(["A0"], outcomes) == %EV{ distribution: %{ 1 => 0.1, -1 => 0.9 }, ev: -0.8 }
    assert EV.of(["B0"], outcomes) == %EV{ distribution: %{ 1 => 0.9, -1 => 0.1 }, ev: 0.8 }
  end
end
