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

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (ronda:lobby).
  @impl true
  def handle_in("shout", %{"name" => name} = payload, socket) do
    QuieroMate.put(name)
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  @impl true
  def handle_info(:after_join, socket) do
    QuieroMate.all()
    |> Enum.reverse()
    |> Enum.each(fn {_, name} ->
      push(socket, "shout", %{name: name})
    end)

    {:noreply, socket}
  end
end
