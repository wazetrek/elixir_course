defmodule Lottery.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Lottery.Server, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_all)
  end
end

# Se recomienda usar alias para facilitar el proceso de llamar a las funciones del servidor de lotería.
# alias Lottery.Server, as: LS
# LS.add_player("Andrés")
# LS.add_player("Lina")
# LS.publish_results("Resultados de la lotería")
# LS.notify_winner()

# Sin Alias
# Lottery.Server.add_player("Andrés")
# Lottery.Server.add_player("Lina")
# Lottery.Server.publish_results("Resultados de la lotería")
# Lottery.Server.notify_winner()
