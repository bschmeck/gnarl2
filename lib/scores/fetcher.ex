defmodule Scores.Fetcher do
  def get do
    feed_url()
    |> fetch
    |> parse
    |> Enum.map(&convert/1)
  end

  def feed_url do
    "https://feeds.nfl.com/feeds-rs/scores.json"
  end

  def fetch(url) do
    HTTPoison.get! url
  end

  def parse(%HTTPoison.Response{body: body}) do
    {:ok, parsed } = body |> Poison.decode

    parsed |> Map.get("gameScores")
  end

  def convert(%{"gameSchedule" => team_data, "score" => score_data}) do
    {:ok, start_time} = team_data |> Map.get("isoTime") |> div(1000) |> DateTime.from_unix

    %Game{
      away_team: team_data |> Map.get("visitorTeam") |> Map.get("abbr"),
      home_team: team_data |> Map.get("homeTeam") |> Map.get("abbr"),
      away_score: score_data |> Map.get("visitorTeamScore") |> Map.get("pointTotal"),
      home_score: score_data |> Map.get("homeTeamScore") |> Map.get("pointTotal"),
      start_time: start_time,
      time_left: score_data |> Map.get("phase")
    }
  end
end
