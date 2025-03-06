defmodule TurnManager do
  use GenServer

  # Default 6 seconds per turn
  @default_interval 6000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{interval: @default_interval, timer_ref: nil},
      name: __MODULE__
    )
  end

  def init(state) do
    new_timer = schedule_next_turn(state.interval)
    {:ok, %{state | timer_ref: new_timer}}
  end

  def manual_turn(:next) do
    GenServer.cast(__MODULE__, :next_turn)
  end

  def manual_turn(:prev) do
    GenServer.cast(__MODULE__, :prev_turn)
  end

  def handle_cast(:next_turn, state) do
    update_turn(:next)
    {:noreply, state}
  end

  def handle_cast(:prev_turn, state) do
    update_turn(:prev)
    {:noreply, state}
  end

  def handle_info(:tick, state) do
    update_turn(:next)
    new_timer = schedule_next_turn(state.interval)
    {:noreply, %{state | timer_ref: new_timer}}
  end

  def get_interval do
    GenServer.call(__MODULE__, :get_interval)
  end

  def handle_call(:get_interval, _from, state) do
    {:reply, state.interval, state}
  end

  def set_interval(new_interval) when is_integer(new_interval) and new_interval > 0 do
    GenServer.call(__MODULE__, {:set_interval, new_interval})
  end

  def handle_call({:set_interval, new_interval}, _from, state) do
    # Cancel the previous timer
    if state.timer_ref, do: Process.cancel_timer(state.timer_ref)

    # Start a new timer with the new interval
    new_timer = schedule_next_turn(new_interval)

    {:reply, :ok, %{interval: new_interval, timer_ref: new_timer}}
  end

  defp update_turn(direction) do
    users = QuieroMate.all() |> Map.keys()

    case users do
      [] ->
        nil

      _ ->
        current_turn = QuieroMate.get_current_turn()
        current_index = Enum.find_index(users, &(&1 == current_turn)) || -1

        next_index =
          case direction do
            :next -> rem(current_index + 1, length(users))
            :prev -> rem(current_index - 1 + length(users), length(users))
          end

        next_id = Enum.at(users, next_index)

        QuieroMate.set_turn(next_id)
        QuieroMateWeb.Endpoint.broadcast("ronda:lobby", "turn", %{id: next_id})
    end
  end

  defp schedule_next_turn(interval) do
    Process.send_after(self(), :tick, interval)
  end
end
