defmodule QuieroMate.Rondas.Ronda do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rondas" do
    field :cebador, :string
    field :users, {:array, :string}

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ronda, attrs) do
    ronda
    |> cast(attrs, [:cebador, :users])
    |> validate_required([:cebador, :users])
  end
end
