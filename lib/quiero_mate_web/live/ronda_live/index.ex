defmodule QuieroMateWeb.RondaLive.Index do
  use QuieroMateWeb, :live_view

  alias QuieroMate.Rondas
  alias QuieroMate.Rondas.Ronda

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :rondas, Rondas.list_rondas())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ronda")
    |> assign(:ronda, Rondas.get_ronda!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ronda")
    |> assign(:ronda, %Ronda{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Rondas")
    |> assign(:ronda, nil)
  end

  @impl true
  def handle_info({QuieroMateWeb.RondaLive.FormComponent, {:saved, ronda}}, socket) do
    {:noreply, stream_insert(socket, :rondas, ronda)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ronda = Rondas.get_ronda!(id)
    {:ok, _} = Rondas.delete_ronda(ronda)

    {:noreply, stream_delete(socket, :rondas, ronda)}
  end
end
