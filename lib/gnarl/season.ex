defmodule Gnarl.Season do
  use Ecto.Schema

  schema "seasons" do
    field :year, :integer
    has_many :weeks, Gnarl.Week
  end
end
