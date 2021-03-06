defmodule GnarlWeb.Router do
  use GnarlWeb, :router

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

  scope "/", GnarlWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", GnarlWeb do
    pipe_through :api

    get "/:season/:week/ev", ApiController, :ev
    get "/:season/:week/scores", ApiController, :scores
  end

  scope "/admin", GnarlWeb do
    pipe_through :browser

    get "/picks", Admin.PicksController, :index
    get "/picks/:season/:week", Admin.PicksController, :show
    post "/picks/:season/:week", Admin.PicksController, :create
  end
end
