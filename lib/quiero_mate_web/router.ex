defmodule QuieroMateWeb.Router do
  use QuieroMateWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {QuieroMateWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", QuieroMateWeb do
    pipe_through(:browser)

    get("/old", PageController, :home)

    get("/", RedirectController, :to_rondas)
    live("/rondas", RondaLive.Index, :index)
    live("/rondas/new", RondaLive.Index, :new)
    live("/rondas/:id/edit", RondaLive.Index, :edit)

    live("/rondas/:id", RondaLive.Show, :show)
    live("/rondas/:id/show/edit", RondaLive.Show, :edit)
  end

  # Other scopes may use custom stacks.
  # scope "/api", QuieroMateWeb do
  #   pipe_through :api
  # end
end
