defmodule HttpStubClient do
  def get("https://feeds.nfl.com/feeds-rs/scores.json") do
    File.read("test/data/scores.json")
  end

  def get("https://nf-api.numberfire.com/v0/gameScores?sport=nfl") do
    File.read("test/data/numberfire.json")
  end
end

defmodule FetcherTest do
  use ExUnit.Case, async: true

  test "it fetches probabilities" do
    {2017, 1, results} = Fetcher.probabilities(HttpStubClient)
    assert Enum.count(results) == 15
    assert Enum.member? results, {"NE", 0.000}
    assert Enum.member? results, {"HOU", 0.679}
    assert Enum.member? results, {"CIN", 0.679}
    assert Enum.member? results, {"WAS", 0.674}
    assert Enum.member? results, {"CLE", 0.276}
    assert Enum.member? results, {"BUF", 0.817}
    assert Enum.member? results, {"TEN", 0.61}
    assert Enum.member? results, {"DET", 0.434}
    assert Enum.member? results, {"CHI", 0.295}
    assert Enum.member? results, {"LAR", 0.489}
    assert Enum.member? results, {"SF", 0.347}
    assert Enum.member? results, {"GB", 0.694}
    assert Enum.member? results, {"DAL", 0.779}
    assert Enum.member? results, {"MIN", 0.503}
    assert Enum.member? results, {"DEN", 0.609}
  end

  test "it fetches scores" do
    {2017, 4, results} = Fetcher.scores(HttpStubClient)
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
