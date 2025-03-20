defmodule QuieroMate do
  use Agent

  @moduledoc """
  QuieroMate stores items in memory using a map, with an auto-incrementing ID as the key.
  """

  # Start the Agent with an initial state: an empty map and a counter at 0
  def start_link(_) do
    Agent.start_link(fn -> %{data: %{}, counter: 0, current_turn: nil, prev_turn: nil} end,
      name: __MODULE__
    )
  end

  # Store a new item in memory with an auto-incrementing ID
  def put(value, id) do
    Agent.update(__MODULE__, fn state ->
      new_data = Map.put(state.data, id, value)

      %{
        state
        | data: new_data,
          counter: state.counter + 1,
          current_turn: state.current_turn || id
      }
    end)
  end

  # Remove an item by ID
  def delete_by_id(id) do
    Agent.update(__MODULE__, fn state ->
      new_data = Map.delete(state.data, id)
      %{state | data: new_data}
    end)
  end

  def set_turn(id) do
    Agent.update(__MODULE__, fn state ->
      %{state | current_turn: id, prev_turn: state.current_turn}
    end)
  end

  # -------- Getters --------
  def get_users do
    data = Agent.get(__MODULE__, & &1.data)
    map_size(data)
  end

  def get(id), do: Agent.get(__MODULE__, &Map.get(&1.data, id))
  def all, do: Agent.get(__MODULE__, & &1.data)
  def get_counter, do: Agent.get(__MODULE__, & &1.counter)
  def get_current_turn, do: Agent.get(__MODULE__, & &1.current_turn)
  def get_prev_turn, do: Agent.get(__MODULE__, & &1.current_turn)
end
