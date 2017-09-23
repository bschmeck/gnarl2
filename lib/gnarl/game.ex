defmodule Gnarl.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    belongs_to :home_team, Gnarl.Team
    belongs_to :away_team, Gnarl.Team
    belongs_to :week, Gnarl.Week
    field :winning_team, :string
  end

  def changeset(game, params \\ %{}) do
    game
    |> cast(params, [:home_team_id, :away_team_id, :week_id, :winning_team])
    |> validate_required([:home_team_id, :away_team_id, :week_id])
    |> validate_inclusion(:winning_team, [nil, "HOME", "AWAY"])
  end
end
