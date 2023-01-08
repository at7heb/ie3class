defmodule Ie3cWeb.PageController do
  use Ie3cWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
