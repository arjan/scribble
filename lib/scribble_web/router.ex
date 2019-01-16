defmodule ScribbleWeb.Router do
  use ScribbleWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ScribbleWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/board/:id", PageController, :board)
    get("/new", PageController, :new)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ScribbleWeb do
  #   pipe_through :api
  # end
end
