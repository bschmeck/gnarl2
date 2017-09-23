defmodule Gnarl.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :abbreviation, :string
      add :franchise_id, references(:franchises)
    end
  end
end
