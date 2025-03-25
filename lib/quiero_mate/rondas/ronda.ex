defmodule QuieroMate.Rondas.Ronda do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rondas" do
    field(:cebador, :string)
    field(:users, {:array, :string}, default: [])

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ronda, attrs) do
    ronda
    |> cast(attrs, [:cebador, :users])
    |> validate_required([:cebador, :users])
    |> validate_length(:cebador, max: 30)
    |> validate_length(:users, max: 7)
  end
end
