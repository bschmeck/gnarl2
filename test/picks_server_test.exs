defmodule PicksServerTest do
  use ExUnit.Case, async: true

  test "it adds picks" do
    state = []
    picks = ~w(GB CHI MIN DET)
    {:noreply, state} = PicksServer.handle_cast({:set_picks, picks}, state)

    assert picks == state
  end

  test "it canonicalizes abbreviations" do
    state = []
    picks = ~w(LAR)

    {:noreply, state} = PicksServer.handle_cast({:set_picks, picks}, state)

    assert state == ~w(LA)
  end
end
