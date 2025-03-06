defmodule TurnManager do
  use GenServer

  # 5 seconds per turn
  @interval 5000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    schedule_next_turn()
    {:ok, nil}
  end

  def handle_info(:tick, state) do
    update_turn()
    schedule_next_turn()
    {:noreply, state}
  end

  defp update_turn do
    users = QuieroMate.all() |> Map.keys()

    case users do
      [] ->
        nil

      _ ->
        current_turn = QuieroMate.get_current_turn()

        # Find the index of the current turn
        current_index = Enum.find_index(users, &(&1 == current_turn)) || -1

        # Get the next index circularly
        next_index = rem(current_index + 1, length(users))

        # Get the next ID from the list
        next_id = Enum.at(users, next_index)

        # Update the turn
        QuieroMate.set_turn(next_id)

        QuieroMateWeb.Endpoint.broadcast("ronda:lobby", "turn", %{id: next_id})
    end
  end

  defp schedule_next_turn do
    Process.send_after(self(), :tick, @interval)
  end
end
