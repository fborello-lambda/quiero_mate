defmodule QuieroMateWeb.RondaLive.UserFormComponent do
  use QuieroMateWeb, :live_component

  alias QuieroMate.Rondas

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage ronda records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="ronda-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:user]} type="text" label="User" />

        <:actions>
          <.button phx-disable-with="Saving...">Quiero Mate</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(state, socket) do
    IO.puts("UPDATE")
    state |> IO.inspect()

    {:ok,
     socket
     |> assign(state)
     |> assign(:form, to_form(%{"user" => ""}))}
  end

  @impl true
  def handle_event("validate", ronda_params, socket) do
    ronda_params |> IO.inspect()
    # TODO: validate user
    _changeset = Rondas.change_ronda(socket.assigns.ronda, ronda_params)
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
         |> put_flash(:info, "User added successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
