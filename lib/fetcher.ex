defmodule Fetcher do
  def probabilities(client \\ HttpClient) do
    {:ok, body} = client.get "https://www.numberfire.com/nfl/games"
    nodes = body |> Floki.find("div.win-probability")

    teams = nodes |> Floki.attribute("class") |> Enum.map(&team_from_classes/1)
    probabilities = nodes |> Floki.find("h4") |> Enum.map(&probability_from_h4/1)

    Enum.zip(teams, probabilities)
  end

  defp team_from_classes(classes) when is_binary(classes), do: classes |> String.split |> team_from_classes
  defp team_from_classes(["team-nfl-" <> team_abbr | _rest]), do: team_abbr
  defp team_from_classes([_head | rest]), do: team_from_classes(rest)

  defp probability_from_h4(node) do
    {prob, "%"} = node |> Floki.find("h4") |> Floki.text |> String.replace(~r/\s/, "") |> Float.parse

    prob / 100 |> Float.round(3)
  end

  def scores(client \\ HttpClient) do
    {:ok, body} = client.get "https://feeds.nfl.com/feeds-rs/scores.json"

    body |> parse |> Enum.map(&convert/1)
  end

  def parse(body) do
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
