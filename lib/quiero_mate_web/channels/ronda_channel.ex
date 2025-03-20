defmodule QuieroMateWeb.RondaChannel do
  use QuieroMateWeb, :channel
  alias QuieroMate

  @impl true
  def join("ronda:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("current_id", _payload, socket) do
    {:reply, {:ok, %{id: QuieroMate.get_counter()}}, socket}
  end

  def handle_in("remove_id", %{"id" => id}, socket) do
    QuieroMate.delete_by_id(String.to_integer(id))
    {:noreply, socket}
  end

  def handle_in("request_id", %{"id" => id}, socket) do
    name = QuieroMate.get(String.to_integer(id))
    SystemNotifier.send_notification("QuieroMate", "#{name} quiere mate!")
    {:noreply, socket}
  end

  def handle_in("turn_manual", %{"dir" => dir}, socket) do
    case dir do
      "next" -> TurnManager.manual_turn(:next)
      "prev" -> TurnManager.manual_turn(:prev)
      _ -> :ok
    end

    {:noreply, socket}
  end

  def handle_in("set_interval", %{"interval" => interval}, socket) do
    TurnManager.set_interval(interval * 1000)
    {:noreply, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (ronda:lobby).
  @impl true
  def handle_in("shout", %{"name" => name, "id" => id}, socket) do
    if QuieroMate.get_users() <= 10 do
      # Insert new person in Agent
      QuieroMate.put(name, id)

      payload = %{name: name, id: id, turn: QuieroMate.get_current_turn()}

      socket
      |> broadcast("shout", payload)

      {:reply, {:ok, %{status: "joined"}}, socket}
    else
      {:reply, {:ok, %{status: "didnt_join"}}, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  @impl true
  def handle_info(:after_join, socket) do
    QuieroMate.all()
    |> Enum.each(fn {id, name} ->
      push(socket, "shout", %{name: name, id: id, turn: QuieroMate.get_current_turn()})
    end)

    {:noreply, socket}
  end
end

defmodule SystemNotifier do
  def send_notification(title, message) do
    case :os.type() do
      {:unix, :linux} ->
        # Linux (Ubuntu, Fedora, etc.)
        System.cmd("notify-send", [title, message])

      {:unix, :darwin} ->
        # macOS
        System.cmd("osascript", [
          "-e",
          "display notification \"#{message}\" with title \"#{title}\""
        ])

      {:win32, _} ->
        # Windows (requires BurntToast module)
        System.cmd("powershell", [
          "-Command",
          "New-BurntToastNotification -Text '#{title}', '#{message}'"
        ])

      _ ->
        {:error, "Unsupported OS"}
    end
  end
end
