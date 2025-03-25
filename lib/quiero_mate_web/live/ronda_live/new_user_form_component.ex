defmodule QuieroMateWeb.RondaLive.UserFormComponent do
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
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:user]} type="text"/>

        <:actions class="flex justify-center w-full">
          <div class="flex justify-center w-full">
            <.button phx-disable-with="Saving..."
            >
              Quiero Mate!
            </.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(state, socket) do
    # TODO: check if this update is strictly required
    {:ok,
     socket
     |> assign(state)
     |> assign(:form, to_form(%{"user" => ""}))}
  end

  @impl true
  def handle_event("validate", %{"user" => user}, socket) do
    # TODO: validate user
    current_users = socket.assigns.ronda.users || []
    updated_users = current_users ++ [user]
    updated_params = %{"users" => updated_users}

    changeset = Rondas.change_ronda(socket.assigns.ronda, updated_params)
    changeset |> IO.inspect()
    {:noreply, socket}
  end

  def handle_event("save", %{"user" => user}, socket) do
    # TODO: validate user, only allow 7 users
    # per ronda
    current_users = socket.assigns.ronda.users || []

    updated_users = current_users ++ [user]

    updated_params = %{"users" => updated_users}

    case Rondas.update_ronda(socket.assigns.ronda, updated_params) do
      {:ok, ronda} ->
        notify_parent({:updated, ronda})

        {:noreply,
         socket
         |> put_flash(:info, "Ingresaste a la ronda como: \"#{user}\"")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error al ingresar a la ronda")
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
