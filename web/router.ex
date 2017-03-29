defmodule Scribble.Router do
  use Scribble.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  forward "/wobserver", Wobserver.Web.Router

  scope "/", Scribble do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/board/:id", PageController, :board
    get "/new", PageController, :new

  end

  # Other scopes may use custom stacks.
  # scope "/api", Scribble do
  #   pipe_through :api
  # end
end
