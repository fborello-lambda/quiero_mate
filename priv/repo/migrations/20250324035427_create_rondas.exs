defmodule QuieroMate.Repo.Migrations.CreateRondas do
  use Ecto.Migration

  def change do
    create table(:rondas) do
      add :cebador, :string
      add :users, {:array, :string}

      timestamps(type: :utc_datetime)
    end
  end
end
