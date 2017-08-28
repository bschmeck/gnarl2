defmodule Scores.FetcherTest do
  use ExUnit.Case

  test "it makes Game structs" do
    game_score = %{"gameSchedule" => %{"gameDate" => "08/27/2017", "gameId" => 2017082753,
                                      "gameKey" => 57217, "gameTimeEastern" => "20:00:00",
                                      "gameTimeLocal" => "19:00:00", "gameType" => "PRE",
                                      "homeDisplayName" => "Minnesota Vikings", "homeNickname" => "Vikings",
                                      "homeTeam" => %{"abbr" => "MIN", "cityState" => "Minnesota",
                                                     "conferenceAbbr" => "NFC", "divisionAbbr" => "NCN",
                                                     "fullName" => "Minnesota Vikings", "nick" => "Vikings", "season" => 2017,
                                                     "teamId" => "3000", "teamType" => "TEAM"}, "homeTeamAbbr" => "MIN",
                                      "homeTeamId" => "3000", "isoTime" => 1503878400000, "season" => 2017,
                                      "seasonType" => "PRE",
                                      "site" => %{"roofType" => "INDOOR", "siteCity" => "Minneapolis",
                                                 "siteFullname" => "U.S. Bank Stadium", "siteId" => 1652,
                                                 "siteState" => "MN"}, "visitorDisplayName" => "San Francisco 49ers",
                                      "visitorNickname" => "49ers",
                                      "visitorTeam" => %{"abbr" => "SF", "cityState" => "San Francisco",
                                                        "conferenceAbbr" => "NFC", "divisionAbbr" => "NCW",
                                                        "fullName" => "San Francisco 49ers", "nick" => "49ers", "season" => 2017,
                                                        "teamId" => "4500", "teamType" => "TEAM"}, "visitorTeamAbbr" => "SF",
                                      "visitorTeamId" => "4500", "week" => 3},
                   "score" => %{"alertPlayType" => nil, "down" => 0,
                               "homeTeamScore" => %{"pointOT" => 0, "pointQ1" => 0, "pointQ2" => 0,
                                                   "pointQ3" => 17, "pointQ4" => 15, "pointTotal" => 32,
                                                   "timeoutsRemaining" => 0}, "phase" => "FINAL",
                               "phaseDescription" => "FINAL", "possessionTeamAbbr" => "MIN",
                               "possessionTeamId" => "3000", "redZone" => false, "time" => "00:00",
                               "visitorTeamScore" => %{"pointOT" => 0, "pointQ1" => 7, "pointQ2" => 7,
                                                      "pointQ3" => 10, "pointQ4" => 7, "pointTotal" => 31,
                                                      "timeoutsRemaining" => 1}, "yardline" => nil, "yardlineNumber" => nil,
                               "yardlineSide" => nil, "yardsToGo" => 0}}
    game = Scores.Fetcher.convert(game_score)
    assert game.home_team == "MIN"
    assert game.away_team == "SF"
    assert game.home_score == 32
    assert game.away_score == 31
    assert {:ok, game.start_time} == DateTime.from_unix(1503878400)
    assert game.time_left == "FINAL"
  end
end
