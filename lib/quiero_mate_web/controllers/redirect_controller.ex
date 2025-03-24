defmodule QuieroMateWeb.RedirectController do
  use QuieroMateWeb, :controller

  def to_rondas(conn, _params) do
    redirect(conn, to: "/rondas")
  end
end
