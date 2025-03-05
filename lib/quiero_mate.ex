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
    Agent.update(__MODULE__, fn %{data: data, counter: counter} ->
      new_data = Map.put(data, id, value)
      %{data: new_data, counter: counter + 1}
    end)
  end

  # Remove an item by ID
  def delete_by_id(id) do
    Agent.update(__MODULE__, fn state ->
      new_data = Map.delete(state.data, id)
      %{state | data: new_data}
    end)
  end

  # Retrieve an item by ID
  def get(id), do: Agent.get(__MODULE__, &Map.get(&1.data, id))
  def all, do: Agent.get(__MODULE__, & &1.data)
  def list, do: Agent.get(__MODULE__, &Map.values(&1.data))
  def get_counter, do: Agent.get(__MODULE__, & &1.counter)
end
