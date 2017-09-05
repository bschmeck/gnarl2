defmodule Fetcher do
  def probabilities(client) do
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

    prob / 100
  end
end
