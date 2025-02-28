defmodule QuieroMateWeb.ErrorJSONTest do
  use QuieroMateWeb.ConnCase, async: true

  test "renders 404" do
    assert QuieroMateWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert QuieroMateWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
