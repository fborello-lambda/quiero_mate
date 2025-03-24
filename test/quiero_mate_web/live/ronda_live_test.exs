defmodule QuieroMateWeb.RondaLiveTest do
  use QuieroMateWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuieroMate.RondasFixtures

  @create_attrs %{cebador: "some cebador", users: ["option1", "option2"]}
  @update_attrs %{cebador: "some updated cebador", users: ["option1"]}
  @invalid_attrs %{cebador: nil, users: []}

  defp create_ronda(_) do
    ronda = ronda_fixture()
    %{ronda: ronda}
  end

  describe "Index" do
    setup [:create_ronda]

    test "lists all rondas", %{conn: conn, ronda: ronda} do
      {:ok, _index_live, html} = live(conn, ~p"/rondas")

      assert html =~ "Listing Rondas"
      assert html =~ ronda.cebador
    end

    test "saves new ronda", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/rondas")

      assert index_live |> element("a", "New Ronda") |> render_click() =~
               "New Ronda"

      assert_patch(index_live, ~p"/rondas/new")

      assert index_live
             |> form("#ronda-form", ronda: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#ronda-form", ronda: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/rondas")

      html = render(index_live)
      assert html =~ "Ronda created successfully"
      assert html =~ "some cebador"
    end

    test "updates ronda in listing", %{conn: conn, ronda: ronda} do
      {:ok, index_live, _html} = live(conn, ~p"/rondas")

      assert index_live |> element("#rondas-#{ronda.id} a", "Edit") |> render_click() =~
               "Edit Ronda"

      assert_patch(index_live, ~p"/rondas/#{ronda}/edit")

      assert index_live
             |> form("#ronda-form", ronda: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#ronda-form", ronda: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/rondas")

      html = render(index_live)
      assert html =~ "Ronda updated successfully"
      assert html =~ "some updated cebador"
    end

    test "deletes ronda in listing", %{conn: conn, ronda: ronda} do
      {:ok, index_live, _html} = live(conn, ~p"/rondas")

      assert index_live |> element("#rondas-#{ronda.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#rondas-#{ronda.id}")
    end
  end

  describe "Show" do
    setup [:create_ronda]

    test "displays ronda", %{conn: conn, ronda: ronda} do
      {:ok, _show_live, html} = live(conn, ~p"/rondas/#{ronda}")

      assert html =~ "Show Ronda"
      assert html =~ ronda.cebador
    end

    test "updates ronda within modal", %{conn: conn, ronda: ronda} do
      {:ok, show_live, _html} = live(conn, ~p"/rondas/#{ronda}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Ronda"

      assert_patch(show_live, ~p"/rondas/#{ronda}/show/edit")

      assert show_live
             |> form("#ronda-form", ronda: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#ronda-form", ronda: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/rondas/#{ronda}")

      html = render(show_live)
      assert html =~ "Ronda updated successfully"
      assert html =~ "some updated cebador"
    end
  end
end
