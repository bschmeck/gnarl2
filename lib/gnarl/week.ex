defmodule Gnarl.Week do
  use Ecto.Schema

  schema "weeks" do
    belongs_to :season, Gnarl.Season
    field :number, :integer
    has_many :games, Gnarl.Game
  end
end
