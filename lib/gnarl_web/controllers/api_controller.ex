defmodule GnarlWeb.ApiController do
  use GnarlWeb, :controller

  def ev(conn, _params) do
    with {:ok, ev} <- PicksServer.ev_of(2017, 10) do
      json conn, ev |> Map.from_struct
    end
  end

  def scores(conn, _params) do
    json conn, [%{"fields": %{"week": 89, "picker": "BEN", "home_team": "PHI", "away_team": "DEN", "picked_team": "PHI", "lock": false, "time_left": "Final", "home_score": 51, "anti_lock": false, "away_score": 23}},
                %{"fields": %{"week": 89, "picker": "BEN", "home_team": "SEA", "away_team": "WAS", "picked_team": "SEA", "lock": false, "time_left": "Final", "home_score": 14, "anti_lock": false, "away_score": 17}},
                %{"fields": %{"week": 89, "picker": "BEN", "home_team": "NYG", "away_team": "LAR", "picked_team": "LAR", "lock": false, "time_left": "Final", "home_score": 17, "anti_lock": true, "away_score": 51}},
                %{"fields": %{"week": 89, "picker": "BEN", "home_team": "NYJ", "away_team": "BUF", "picked_team": "BUF", "lock": false, "time_left": "Final", "home_score": 34, "anti_lock": false, "away_score": 21}},
                %{"fields": %{"week": 89, "picker": "BEN", "home_team": "DAL", "away_team": "KC", "picked_team": "KC", "lock": false, "time_left": "Final", "home_score": 28, "anti_lock": false, "away_score": 17}},
                %{"fields": %{"week": 89, "picker": "BEN", "home_team": "GB", "away_team": "DET", "picked_team": "DET", "lock": true, "time_left": "Final", "home_score": 17, "anti_lock": false, "away_score": 30}},
                %{"fields": %{"week": 89, "picker": "BRIAN", "home_team": "HOU", "away_team": "IND", "picked_team": "HOU", "lock": false, "time_left": "Final", "home_score": 14, "anti_lock": false, "away_score": 20}},
                %{"fields": %{"week": 89, "picker": "BRIAN", "home_team": "NO", "away_team": "TB", "picked_team": "NO", "lock": false, "time_left": "Final", "home_score": 30, "anti_lock": true, "away_score": 10}},
                %{"fields": %{"week": 89, "picker": "BRIAN", "home_team": "JAC", "away_team": "CIN", "picked_team": "JAC", "lock": false, "time_left": "Final", "home_score": 23, "anti_lock": false, "away_score": 7}},
                %{"fields": %{"week": 89, "picker": "BRIAN", "home_team": "TEN", "away_team": "BAL", "picked_team": "TEN", "lock": false, "time_left": "Final", "home_score": 23, "anti_lock": false, "away_score": 20}},
                %{"fields": %{"week": 89, "picker": "BRIAN", "home_team": "MIA", "away_team": "OAK", "picked_team": "OAK", "lock": true, "time_left": "Final", "home_score": 24, "anti_lock": false, "away_score": 27}},
                %{"fields": %{"week": 89, "picker": "BRIAN", "home_team": "CAR", "away_team": "ATL", "picked_team": "CAR", "lock": false, "time_left": "Final", "home_score": 20, "anti_lock": false, "away_score": 17}}]
  end
end
