defmodule Scores.Fetcher do
  alias Scores.Week, as: Week

  def get(week) do
    week
    |> url_for
    |> fetch
    |> parse
  end

  def url_for(%Week{season: season, week: week}) do
    "http://www.nfl.com/scores/#{season}/REG#{week}"
  end

  def fetch(url) do
    HTTPoison.get! url
  end

  def parse(response) do
    response
  end
end
