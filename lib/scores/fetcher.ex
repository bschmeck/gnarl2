defmodule Scores.Fetcher do
  alias Scores.Week, as: Week

  def get(week) do
    week
    |> url_for
    |> fetch
    |> parse
    |> Enum.each(&convert/1)
  end

  def url_for(%Week{season: season, week: week}) do
    "http://www.nfl.com/scores/#{season}/REG#{week}"
  end

  def fetch(url) do
    HTTPoison.get! url
  end

  def parse(%HTTPoison.Response{body: body}) do
    body |> Floki.find("div.scorebox-wrapper")
  end

  def convert(dom) do
    home_team = dom |> team_name("home")
    away_team = dom |> team_name("away")

    "#{away_team} @ #{home_team}"
  end

  def team_name(dom, type) when type == "home" or type == "away" do
    dom |> Floki.find("div.#{type}-team > div.team-data > div.team-info > p.team-name") |> Floki.text
  end
end
