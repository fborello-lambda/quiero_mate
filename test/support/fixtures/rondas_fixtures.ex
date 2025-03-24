defmodule QuieroMate.RondasFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuieroMate.Rondas` context.
  """

  @doc """
  Generate a ronda.
  """
  def ronda_fixture(attrs \\ %{}) do
    {:ok, ronda} =
      attrs
      |> Enum.into(%{
        creator: "some creator",
        rid: 42,
        users: ["option1", "option2"]
      })
      |> QuieroMate.Rondas.create_ronda()

    ronda
  end

  @doc """
  Generate a ronda.
  """
  def ronda_fixture(attrs \\ %{}) do
    {:ok, ronda} =
      attrs
      |> Enum.into(%{
        cebador: "some cebador",
        users: ["option1", "option2"]
      })
      |> QuieroMate.Rondas.create_ronda()

    ronda
  end
end
