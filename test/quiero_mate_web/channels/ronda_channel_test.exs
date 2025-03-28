defmodule QuieroMateWeb.RondaChannelTest do
  use QuieroMateWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      QuieroMateWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(QuieroMateWeb.RondaChannel, "ronda:lobby")

    %{socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply(ref, :ok, %{"hello" => "there"})
  end

  test "shout broadcasts to ronda:lobby", %{socket: socket} do
    push(socket, "shout", %{name: "name", id: "1"})
    assert_broadcast("shout", %{name: "name", id: "1"})
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push("broadcast", %{"some" => "data"})
  end
end
