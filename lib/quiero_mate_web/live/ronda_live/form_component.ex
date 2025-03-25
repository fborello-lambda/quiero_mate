defmodule QuieroMateWeb.RondaLive.FormComponent do
  use QuieroMateWeb, :live_component

  alias QuieroMate.Rondas

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="ronda-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:cebador]} type="text" label={if @title == "Nueva Ronda", do: "Cebador", else: nil} />
        <:actions class="flex justify-center w-full">
          <div class="flex justify-center w-full">
            <.button phx-disable-with="Saving..."
            >
              Guardar Ronda
            </.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{ronda: ronda} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Rondas.change_ronda(ronda))
     end)}
  end

  @impl true
  def handle_event("validate", %{"ronda" => ronda_params}, socket) do
    changeset = Rondas.change_ronda(socket.assigns.ronda, ronda_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"ronda" => ronda_params}, socket) do
    save_ronda(socket, socket.assigns.action, ronda_params)
  end

  defp save_ronda(socket, :edit, ronda_params) do
    case Rondas.update_ronda(socket.assigns.ronda, ronda_params) do
      {:ok, ronda} ->
        notify_parent({:saved, ronda})

        {:noreply,
         socket
         |> put_flash(:info, "Ronda updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_ronda(socket, :new, ronda_params) do
    case Rondas.create_ronda(ronda_params) do
      {:ok, ronda} ->
        notify_parent({:saved, ronda})

        {:noreply,
         socket
         |> put_flash(:info, "Ronda created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
