defmodule QuieroMateWeb.RondaLive.Show do
  use QuieroMateWeb, :live_view

  alias QuieroMate.Rondas

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:ronda, Rondas.get_ronda!(id))}
  end

  defp page_title(:show), do: "Show Ronda"
  defp page_title(:edit), do: "Edit Ronda"
end
