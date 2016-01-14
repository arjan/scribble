defmodule Scribble.PageController do
  use Scribble.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
