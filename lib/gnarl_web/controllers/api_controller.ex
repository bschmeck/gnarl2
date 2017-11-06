defmodule GnarlWeb.ApiController do
  use GnarlWeb, :controller

  def ev(conn, _params) do
    with {:ok, ev} <- PicksServer.ev_of(2017, 9) do
      json conn, ev |> Map.from_struct
    end
  end
end
