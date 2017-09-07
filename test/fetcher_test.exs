defmodule HttpStubClient do
  def get("https://www.numberfire.com/nfl/games") do
    File.read("test/data/numberfire.html")
  end

  def get("https://feeds.nfl.com/feeds-rs/scores.json") do
    File.read("test/data/scores.json")
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
    assert Enum.member? results, {"PIT", 0.724}
    assert Enum.member? results, {"BUF", 0.822}
    assert Enum.member? results, {"MIA", 0.521}
    assert Enum.member? results, {"TEN", 0.61}
    assert Enum.member? results, {"ARI", 0.552}
    assert Enum.member? results, {"ATL", 0.705}
    assert Enum.member? results, {"IND", 0.56}
    assert Enum.member? results, {"CAR", 0.653}
    assert Enum.member? results, {"GB", 0.694}
    assert Enum.member? results, {"DAL", 0.781}
    assert Enum.member? results, {"MIN", 0.503}
    assert Enum.member? results, {"DEN", 0.609}
  end

  test "it fetches scores" do
    results = Fetcher.scores(HttpStubClient)
    assert Enum.count(results) == 2

    game = results |> Enum.at(0)
    assert game.home_team == "NYJ"
    assert game.away_team == "PHI"
    assert game.home_score == 0
    assert game.away_score == 0
    assert {:ok, game.start_time} == DateTime.from_unix(1504220400)
    assert game.time_left == "PREGAME"

    game = results |> Enum.at(1)
    assert game.home_team == "MIN"
    assert game.away_team == "MIA"
    assert game.home_score == 9
    assert game.away_score == 30
    assert {:ok, game.start_time} == DateTime.from_unix(1504224000)
    assert game.time_left == "FINAL"
  end
end
