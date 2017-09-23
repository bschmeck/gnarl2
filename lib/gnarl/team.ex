defmodule Gnarl.Team do
  use Ecto.Schema

  schema "teams" do
    field :name, :string
    field :abbreviation, :string
    belongs_to :franchise, Gnarl.Franchise
    has_many :home_games, Gnarl.Game, foreign_key: :home_team_id
    has_many :away_games, Gnarl.Game, foreign_key: :away_team_id
  end
end
