defmodule Gnarl.Repo.Migrations.CreateSeasons do
  use Ecto.Migration

  def change do
    create table(:seasons) do
      add :year, :integer
    end
  end
end
