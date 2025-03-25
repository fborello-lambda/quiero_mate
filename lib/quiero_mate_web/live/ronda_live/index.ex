defmodule QuieroMateWeb.RondaLive.Index do
  use QuieroMateWeb, :live_view

  alias QuieroMate.Rondas
  alias QuieroMate.Rondas.Ronda
  alias Phoenix.PubSub

  def topic(), do: "lobby"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(QuieroMate.PubSub, topic())
    end

    {:ok, stream(socket, :rondas, Rondas.list_rondas())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Cambiar Cebador")
    |> assign(:ronda, Rondas.get_ronda!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nueva Ronda")
    |> assign(:ronda, %Ronda{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Rondas")
    |> assign(:ronda, nil)
  end

  @impl true
  def handle_info({QuieroMateWeb.RondaLive.FormComponent, {:saved, ronda}}, socket) do
    PubSub.broadcast(QuieroMate.PubSub, topic(), {:ronda_saved, ronda})

    {:noreply, stream_insert(socket, :rondas, ronda)}
  end

  @impl true
  def handle_info({:ronda_saved, ronda}, socket) do
    # Insert the new or updated ronda into the stream for all clients
    {:noreply, stream_insert(socket, :rondas, ronda)}
  end

  @impl true
  def handle_info({:ronda_deleted, ronda}, socket) do
    # Delete the ronda into the stream for all clients
    {:noreply, stream_delete(socket, :rondas, ronda)}
  end

  @impl true
  def handle_info({:new_user, ronda}, socket) do
    # Insert the ronda with the new user into the stream for all clients
    {:noreply, stream_insert(socket, :rondas, ronda)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ronda = Rondas.get_ronda!(id)
    {:ok, _} = Rondas.delete_ronda(ronda)

    PubSub.broadcast(QuieroMate.PubSub, topic(), {:ronda_deleted, ronda})

    {:noreply, stream_delete(socket, :rondas, ronda)}
  end
end
