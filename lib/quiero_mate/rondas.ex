defmodule QuieroMate.Rondas do
  @moduledoc """
  The Rondas context.
  """

  import Ecto.Query, warn: false
  alias QuieroMate.Repo

  alias QuieroMate.Rondas.Ronda

  @doc """
  Returns the list of rondas.

  ## Examples

      iex> list_rondas()
      [%Ronda{}, ...]

  """
  def list_rondas do
    Repo.all(Ronda)
  end

  @doc """
  Gets a single ronda.

  Raises `Ecto.NoResultsError` if the Ronda does not exist.

  ## Examples

      iex> get_ronda!(123)
      %Ronda{}

      iex> get_ronda!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ronda!(id), do: Repo.get!(Ronda, id)

  @doc """
  Creates a ronda.

  ## Examples

      iex> create_ronda(%{field: value})
      {:ok, %Ronda{}}

      iex> create_ronda(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ronda(attrs \\ %{}) do
    %Ronda{}
    |> Ronda.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ronda.

  ## Examples

      iex> update_ronda(ronda, %{field: new_value})
      {:ok, %Ronda{}}

      iex> update_ronda(ronda, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ronda(%Ronda{} = ronda, attrs) do
    ronda
    |> Ronda.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ronda.

  ## Examples

      iex> delete_ronda(ronda)
      {:ok, %Ronda{}}

      iex> delete_ronda(ronda)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ronda(%Ronda{} = ronda) do
    Repo.delete(ronda)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ronda changes.

  ## Examples

      iex> change_ronda(ronda)
      %Ecto.Changeset{data: %Ronda{}}

  """
  def change_ronda(%Ronda{} = ronda, attrs \\ %{}) do
    Ronda.changeset(ronda, attrs)
  end
end
