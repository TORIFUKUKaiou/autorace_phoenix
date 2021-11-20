defmodule AutoracePhoenixWeb.PageController do
  use AutoracePhoenixWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
