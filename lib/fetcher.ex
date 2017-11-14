defmodule Fetcher do
  def probabilities(client \\ HttpClient) do
    with {:ok, body} <- client.get("https://nf-api.numberfire.com/v0/gameScores?sport=nfl"),
         {:ok, [first | _rest] = json} <- body |> Poison.decode,
         %{"scoreboard" => %{"season" => season, "week" => week}} <- first,
           probs <- json |> Enum.map(&tuple_from_game/1) |> Enum.map(&format_tuple/1),
    do: {season, week, probs}
  end

  defp tuple_from_game(%{"scoreboard" => %{"home_team" => %{"abbrev" => abbrev}, "game_status" => "FINAL", "home_team_id" => home_id, "winner_id" => winner_id}}) when is_binary(winner_id) do
    tuple_from_game(%{"scoreboard" => %{"home_team" => %{"abbrev" => abbrev}, "game_status" => "FINAL", "home_team_id" => home_id, "winner_id" => String.to_integer(winner_id)}})
  end
  defp tuple_from_game(%{"scoreboard" => %{"home_team" => %{"abbrev" => abbrev}, "game_status" => "FINAL", "home_team_id" => home_id, "winner_id" => home_id}}), do: {abbrev, 100}
  defp tuple_from_game(%{"scoreboard" => %{"home_team" => %{"abbrev" => abbrev}, "game_status" => "FINAL"}}), do: {abbrev, 0}
  defp tuple_from_game(%{"scoreboard" => %{"home_team" => %{"abbrev" => abbrev}, "homeWP" => prob}}), do: {abbrev, prob}
  defp tuple_from_game(%{"scoreboard" => %{"home_team" => %{"abbrev" => abbrev}, "pregame_home_wp" => prob}}), do: {abbrev, prob}

  defp format_tuple({abbrev, prob}), do: {Canonicalize.team_abbr(abbrev), Float.round(prob / 100, 3)}

  def scores(client \\ HttpClient) do
    with {:ok, body} <- client.get("https://feeds.nfl.com/feeds-rs/scores.json"),
         {:ok, json} <- body |> Poison.decode,
         %{"season" => season, "week" => week, "gameScores" => raw_scores} <- json,
         game_scores <- raw_scores |> Enum.map(&convert/1),
    do: {season, week, game_scores}
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
  def time_left(%{"score" => %{"phase" => "FINAL"}}), do: "Final"
  def time_left(%{"score" => %{"phase" => "FINAL_OVERTIME"}}), do: "Final"
  def time_left(%{"score" => %{"phase" => "HALFTIME"}}), do: "HALFTIME"
  def time_left(%{"score" => %{"phase" => "PREGAME"}}), do: "PREGAME"

  def time_left(%{"score" => %{"phase" => phase, "time" => time}}), do: "#{time} #{phase}"

  def score(%{"score" => nil}, _side), do: 0
  def score(%{"score" => %{"visitorTeamScore" => %{"pointTotal" => total}}}, :away), do: total
  def score(%{"score" => %{"homeTeamScore" => %{"pointTotal" => total}}}, :home), do: total

  def team_abbr(%{"gameSchedule" => %{"visitorTeam" => %{"abbr" => abbr}}}, :away), do: abbr
  def team_abbr(%{"gameSchedule" => %{"homeTeam" => %{"abbr" => abbr}}}, :home), do: abbr
end
