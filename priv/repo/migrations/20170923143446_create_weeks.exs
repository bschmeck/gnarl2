defmodule Gnarl.Repo.Migrations.CreateWeeks do
  use Ecto.Migration

  def change do
    create table(:weeks) do
      add :season_id, references(:seasons)
      add :number, :integer
    end
  end
end
