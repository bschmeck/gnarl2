defmodule Gnarl.Franchise do
  use Ecto.Schema

  schema "franchises" do
    field :name, :string
    has_many :teams, Gnarl.Team
  end
end
