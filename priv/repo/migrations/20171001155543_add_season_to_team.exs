defmodule Gnarl.Repo.Migrations.AddSeasonToTeam do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :season_id, references(:seasons)
    end
  end
end
