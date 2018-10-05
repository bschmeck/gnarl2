defmodule Gnarl.Repo.Migrations.CreatePicks do
  use Ecto.Migration

  def change do
    create table("picks") do
      add :picker, :string, size: 40, null: false
      add :winner, :string, size: 3, null: false
      add :slot, :integer, null: false
      add :lock, :boolean, default: false, null: false
      add :antilock, :boolean, default: false, null: false
      add :season, :integer, null: false
      add :week, :integer, null: false

      timestamps()
    end
  end
end
