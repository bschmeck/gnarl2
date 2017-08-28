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

  def convert(%{"gameSchedule" => team_data, "score" => _score}) do
    home_team = team_data |> Map.get("homeTeam") |> Map.get("abbr")
    away_team = team_data |> Map.get("visitorTeam") |> Map.get("abbr")

    "#{away_team} @ #{home_team}"
  end
end
