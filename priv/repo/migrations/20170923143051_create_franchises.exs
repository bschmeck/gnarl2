defmodule Gnarl.Repo.Migrations.CreateFranchises do
  use Ecto.Migration

  def change do
    create table(:franchises) do
      add :name, :string
    end
  end
end
