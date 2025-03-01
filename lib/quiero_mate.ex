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
  def put(value) do
    Agent.get_and_update(__MODULE__, fn %{data: data, counter: counter} ->
      new_counter = counter + 1
      new_data = Map.put(data, new_counter, value)
      {new_counter, %{data: new_data, counter: new_counter}}
    end)
  end

  # Retrieve an item by ID
  def get(id) do
    Agent.get(__MODULE__, &Map.get(&1.data, id))
  end

  # Remove the most recent item (highest ID) and decrement the counter
  def pop do
    Agent.get_and_update(__MODULE__, fn %{data: data, counter: counter} ->
      if counter > 0 do
        {Map.get(data, counter), %{data: Map.delete(data, counter), counter: counter - 1}}
      else
        # If empty, reset
        {nil, %{data: %{}, counter: 0}}
      end
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
