defmodule Gnarl.Team do
  use Ecto.Schema

  schema "teams" do
    field :name, :string
    field :abbreviation, :string
    belongs_to :franchise, Gnarl.Franchise
  end
end
