defmodule Gnarl.Game do
  use Ecto.Schema

  schema "games" do
    belongs_to :home_team, Gnarl.Team
    belongs_to :away_team, Gnarl.Team
    belongs_to :week, Gnarl.Week
    field :winning_team, :string
  end
end
