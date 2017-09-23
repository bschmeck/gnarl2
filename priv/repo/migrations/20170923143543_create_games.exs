defmodule Gnarl.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :home_team_id, references(:teams)
      add :away_team_id, references(:teams)
      add :week_id, references(:weeks)
      add :winning_team, :string
    end
  end
end
