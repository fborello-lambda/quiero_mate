defmodule QuieroMateWeb.RondaLive.Show do
  use QuieroMateWeb, :live_view

  alias QuieroMateWeb.Presence
  alias QuieroMate.Rondas
  alias Phoenix.PubSub

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    initial_present =
      if connected?(socket) do
        IO.puts("Subscribing to presence topic: #{id}")
        QuieroMateWeb.Presence.track(self(), id, socket.id, %{})
        PubSub.subscribe(QuieroMate.PubSub, id)

        Presence.list(id) |> map_size()
      else
        0
      end

    {:ok,
     socket
     |> assign(:topic, id)
     |> assign(:present, initial_present)
     |> assign(:form, to_form(%{"user" => ""}))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:ronda, Rondas.get_ronda!(id))}
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{present: present}} = socket
      ) do
    {_, joins} = Map.pop(joins, socket.id)
    new_present = present + map_size(joins) - map_size(leaves)
    {:noreply, assign(socket, :present, new_present)}
  end

  @impl true
  def handle_info({QuieroMateWeb.RondaLive.UserFormComponent, {:updated, ronda}}, socket) do
    IO.puts("UserFormComponent updated")

    PubSub.broadcast(QuieroMate.PubSub, socket.assigns.topic, {:new_user, ronda})
    PubSub.broadcast(QuieroMate.PubSub, "lobby", {:new_user, ronda})

    {:noreply, socket |> assign(:ronda, ronda)}
  end

  @impl true
  def handle_info({:new_user, ronda}, socket) do
    IO.puts("New user added")
    {:noreply, socket |> assign(:ronda, ronda)}
  end

  defp page_title(:show), do: "Show Ronda"
  defp page_title(:edit), do: "Edit Ronda"
end
