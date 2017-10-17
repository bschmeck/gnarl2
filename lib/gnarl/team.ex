defmodule Gnarl.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    field :abbreviation, :string
    belongs_to :franchise, Gnarl.Franchise
    has_many :home_games, Gnarl.Game, foreign_key: :home_team_id
    has_many :away_games, Gnarl.Game, foreign_key: :away_team_id
    belongs_to :season, Gnarl.Season
  end

  def changeset(team, params \\ %{}) do
    team
    |> cast(params, [:name, :abbreviation, :franchise_id, :season_id])
    |> validate_required([:name, :abbreviation, :franchise_id, :season_id])
  end
end
