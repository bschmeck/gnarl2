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
    {:ok, parsed} = body |> Poison.decode

    parsed |> Map.get("gameScores")
  end

  def convert(game_map) do
    %Game{
      away_team: game_map |> team_abbr(:away),
      home_team: game_map |> team_abbr(:home),
      away_score: game_map |> score(:away),
      home_score: game_map |> score(:home),
      start_time: game_map |> start_time,
      time_left: game_map |> time_left
    }
  end

  def start_time(%{"gameSchedule" => %{"isoTime" => iso_time}}) do
    {:ok, start_time} = iso_time |> div(1000) |> DateTime.from_unix

    start_time
  end

  def time_left(%{"score" => nil}), do: "PREGAME"
  def time_left(%{"score" => %{"phase" => "FINAL"}}), do: "FINAL"
  def time_left(%{"score" => %{"phase" => "HALFTIME"}}), do: "HALFTIME"
  def time_left(%{"score" => %{"phase" => "PREGAME"}}), do: "PREGAME"

  def time_left(%{"score" => %{"phase" => phase, "time" => time}}), do: "#{time} #{phase}"

  def score(%{"score" => nil}, _side), do: 0
  def score(%{"score" => %{"visitorTeamScore" => %{"pointTotal" => total}}}, :away), do: total
  def score(%{"score" => %{"homeTeamScore" => %{"pointTotal" => total}}}, :home), do: total

  def team_abbr(%{"gameSchedule" => %{"visitorTeam" => %{"abbr" => abbr}}}, :away), do: abbr
  def team_abbr(%{"gameSchedule" => %{"homeTeam" => %{"abbr" => abbr}}}, :home), do: abbr
end
