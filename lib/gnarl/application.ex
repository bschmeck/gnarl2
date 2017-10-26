defmodule Gnarl.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Gnarl.Repo, []),
      worker(GameServer, []),
      worker(PicksServer, [])
    ]

    opts = [strategy: :one_for_one, name: Gnarl.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
