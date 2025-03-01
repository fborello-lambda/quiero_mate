defmodule QuieroMate do
  use Agent

  @moduledoc """
  QuieroMate stores items in memory using a map, with an auto-incrementing ID as the key.
  """

  # Start the Agent with an initial state: an empty map and a counter at 0
  def start_link(_) do
    Agent.start_link(fn -> %{data: %{}, counter: 0} end, name: __MODULE__)
  end

  # Store a new item in memory with an auto-incrementing ID
  def put(value, id) do
    Agent.get_and_update(__MODULE__, fn %{data: data, counter: counter} ->
      new_counter = counter + 1
      new_data = Map.put(data, id, value)
      {new_counter, %{data: new_data, counter: new_counter}}
    end)
  end

  # Retrieve an item by ID
  def get(id) do
    Agent.get(__MODULE__, &Map.get(&1.data, id))
  end

  # Remove an item by ID
  def delete_by_id(id) do
    Agent.get_and_update(__MODULE__, fn %{data: data, counter: counter} ->
      new_data = Map.delete(data, id)
      {counter, %{data: new_data, counter: counter}}
    end)
  end

  # Get all stored values
  def all() do
    Agent.get(__MODULE__, & &1.data)
  end

  # Get the current highest ID
  def get_counter do
    Agent.get(__MODULE__, & &1.counter)
  end

  # Debug function to print the current state
  def debug do
    IO.inspect(Agent.get(__MODULE__, & &1), label: "QuieroMate State")
  end
end
