defmodule HttpStubClient do
  def get("https://www.numberfire.com/nfl/games") do
    File.read("numberfire.html")
  end
end

defmodule FetcherTest do
  use ExUnit.Case

  test "it fetches probabilities" do
    results = Fetcher.probabilities(HttpStubClient)
    assert Enum.count(results) == 16
    assert Enum.member? results, {"NE", 0.708}
    assert Enum.member? results, {"HOU", 0.679}
    assert Enum.member? results, {"CIN", 0.679}
    assert Enum.member? results, {"WSH", 0.675}
    assert Enum.member? results, {"PIT", 0.7240000000000001}
    assert Enum.member? results, {"BUF", 0.8220000000000001}
    assert Enum.member? results, {"MIA", 0.521}
    assert Enum.member? results, {"TEN", 0.61}
    assert Enum.member? results, {"ARI", 0.552}
    assert Enum.member? results, {"ATL", 0.705}
    assert Enum.member? results, {"IND", 0.56}
    assert Enum.member? results, {"CAR", 0.653}
    assert Enum.member? results, {"GB", 0.6940000000000001}
    assert Enum.member? results, {"DAL", 0.7809999999999999}
    assert Enum.member? results, {"MIN", 0.503}
    assert Enum.member? results, {"DEN", 0.609}
  end
end
