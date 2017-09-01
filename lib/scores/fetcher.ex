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
    %Game{
      away_team: team_data |> team_abbr(:away),
      home_team: team_data |> team_abbr(:home),
      away_score: score_data |> score(:away),
      home_score: score_data |> score(:home),
      start_time: team_data |> start_time,
      time_left: score_data |> time_left
    }
  end

  def start_time(%{"isoTime" => iso_time}) do
    {:ok, start_time} = iso_time |> div(1000) |> DateTime.from_unix

    start_time
  end

  def time_left(%{"phase" => "FINAL"}), do: "FINAL"
  def time_left(%{"phase" => "HALFTIME"}), do: "HALFTIME"
  def time_left(%{"phase" => "PREGAME"}), do: "PREGAME"
  def time_left(nil), do: "PREGAME"
  def time_left(%{"phase" => phase, "time" => time}), do: "#{time} #{phase}"

  def score(nil, _side), do: 0
  def score(%{"visitorTeamScore" => %{"pointTotal" => total}}, :away), do: total
  def score(%{"homeTeamScore" => %{"pointTotal" => total}}, :home), do: total

  def team_abbr(%{"visitorTeam" => %{"abbr" => abbr }}, :away), do: abbr
  def team_abbr(%{"homeTeam" => %{"abbr" => abbr }}, :home), do: abbr
end
