defmodule HttpStubClient do
  def get("https://www.numberfire.com/nfl/games") do
    File.read("numberfire.html")
  end

  def get("https://feeds.nfl.com/feeds-rs/scores.json") do
    File.read("scores.4.json")
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

  test "it fetches scores" do
    results = Fetcher.scores(HttpStubClient)
    assert Enum.count(results) == 15

    game = Enum.find(results, fn(game) -> game.home_team == "MIN" end)
    assert game.home_team == "MIN"
    assert game.away_team == "MIA"
    assert game.home_score == 9
    assert game.away_score == 30
    assert {:ok, game.start_time} == DateTime.from_unix(1504224000)
    assert game.time_left == "FINAL"

    game = Enum.find(results, fn(game) -> game.home_team == "NYJ" end)
    assert game.home_team == "NYJ"
    assert game.away_team == "PHI"
    assert game.home_score == 0
    assert game.away_score == 0
    assert {:ok, game.start_time} == DateTime.from_unix(1504220400)
    assert game.time_left == "PREGAME"
  end
end
